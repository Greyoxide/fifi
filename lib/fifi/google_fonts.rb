# frozen_string_literal: true

require "fileutils"
require "json"
require "open-uri"

module Fifi
  class GoogleFonts
    REPO_API_BASE = "https://api.github.com/repos/google/fonts/contents"
    LICENSE_DIRS = %w[ofl apache ufl].freeze

    def initialize(font_name, variable: true)
      @font_name = font_name
      @variable = variable
    end

    def fetch(destination_dir)
      files = resolve_files
      FileUtils.mkdir_p(destination_dir)

      files.map do |file|
        target = File.join(destination_dir, file[:name])
        download_file(file[:url], target)
        target
      end
    end

    private

    def resolve_files
      family_url = find_family_dir
      raise "Font family not found in Google Fonts repo" unless family_url

      entries = fetch_json(family_url)
      static_dir = entries.find { |entry| entry["type"] == "dir" && entry["name"] == "static" }
      root_fonts = entries.select { |entry| entry["type"] == "file" && font_file?(entry["name"]) }
      variable_fonts = root_fonts.select { |entry| variable_file?(entry["name"]) }
      static_root_fonts = root_fonts.reject { |entry| variable_file?(entry["name"]) }

      chosen = if @variable
        if variable_fonts.any?
          variable_fonts
        elsif static_dir
          list_static_dir(static_dir["url"])
        else
          static_root_fonts.empty? ? root_fonts : static_root_fonts
        end
      else
        if static_dir
          list_static_dir(static_dir["url"])
        elsif static_root_fonts.any?
          static_root_fonts
        else
          variable_fonts.empty? ? root_fonts : variable_fonts
        end
      end

      chosen.map { |entry| { name: entry["name"], url: entry["download_url"] } }
            .reject { |entry| entry[:url].nil? }
    end

    def list_static_dir(url)
      entries = fetch_json(url)
      entries.select { |entry| entry["type"] == "file" && font_file?(entry["name"]) }
    end

    def find_family_dir
      normalized = normalize_family(@font_name)
      LICENSE_DIRS.each do |dir|
        url = "#{REPO_API_BASE}/#{dir}/#{normalized}"
        return url if url_exists?(url)
      end
      nil
    end

    def url_exists?(url)
      fetch_json(url)
      true
    rescue OpenURI::HTTPError => e
      return false if e.message.include?("404")
      raise "GitHub API error: #{e.message}"
    end

    def fetch_json(url)
      raw = URI.open(url, github_headers).read
      JSON.parse(raw)
    rescue OpenURI::HTTPError => e
      raise "GitHub API error for #{url}: #{e.message}"
    rescue JSON::ParserError => e
      raise "Unexpected response from GitHub API for #{url}: #{e.message}"
    end

    def download_file(url, target)
      URI.open(url, "rb", **github_headers) do |io|
        File.open(target, "wb") { |file| IO.copy_stream(io, file) }
      end
    rescue OpenURI::HTTPError => e
      raise "Failed to download #{@font_name} (#{e.message})"
    end

    def github_headers
      headers = { "User-Agent" => "fifi" }
      token = ENV["FIFI_GITHUB_TOKEN"] || ENV["GITHUB_TOKEN"]
      headers["Authorization"] = "token #{token}" if token && !token.empty?
      headers
    end

    def normalize_family(name)
      name.downcase.gsub(/[^a-z0-9]/, "")
    end

    def font_file?(name)
      name.match?(/\.(ttf|otf)$/i)
    end

    def variable_file?(name)
      name.match?(/\[.+\]/) || name.match?(/VariableFont|\\bVF\\b/i)
    end
  end
end
