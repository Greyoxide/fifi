# frozen_string_literal: true

require "optparse"
require "fileutils"
require "fifi/google_fonts"

module Fifi
  class CLI
    def self.start(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      return show_usage if @argv.empty?
      return show_usage if help_flag?(@argv.first)

      command = @argv.shift
      case command
      when "install"
        run_install(@argv)
      when "download"
        run_download(@argv)
      else
        warn "Unknown command: #{command}"
        show_usage(exit_code: 1)
      end
    end

    private

    def run_install(args)
      options = { variable: true }
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: fifi install <fonts> [options]"
        opts.on("-s", "--static", "Prefer static fonts (default: variable)") do
          options[:variable] = false
        end
        opts.on("-h", "--help", "Show help") do
          puts opts
          return 0
        end
      end

      parser.parse!(args)
      fonts = parse_fonts(args)
      if fonts.empty?
        warn "No fonts provided."
        puts parser
        return 1
      end

      font_dir = default_font_dir
      failures = 0

      fonts.each do |font|
        begin
          files = GoogleFonts.new(font, variable: options[:variable]).fetch(font_dir)
          puts "Installed #{font} (#{files.size} files) to #{font_dir}"
        rescue StandardError => e
          failures += 1
          warn "Failed to install #{font}: #{e.message}"
        end
      end

      if linux_platform? && failures < fonts.size
        puts "If fonts are not visible, run: fc-cache -f"
      end

      failures.zero? ? 0 : 1
    end

    def run_download(args)
      options = { variable: true, output: Dir.pwd }
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: fifi download <fonts> [options]"
        opts.on("-o", "--output DIR", "Output directory (default: current dir)") do |dir|
          options[:output] = dir
        end
        opts.on("-s", "--static", "Prefer static fonts (default: variable)") do
          options[:variable] = false
        end
        opts.on("-h", "--help", "Show help") do
          puts opts
          return 0
        end
      end

      parser.parse!(args)
      fonts = parse_fonts(args)
      if fonts.empty?
        warn "No fonts provided."
        puts parser
        return 1
      end

      failures = 0

      fonts.each do |font|
        begin
          files = GoogleFonts.new(font, variable: options[:variable]).fetch(options[:output])
          puts "Downloaded #{font} (#{files.size} files) to #{options[:output]}"
        rescue StandardError => e
          failures += 1
          warn "Failed to download #{font}: #{e.message}"
        end
      end

      failures.zero? ? 0 : 1
    end

    def parse_fonts(args)
      raw = args.join(" ").strip
      return [] if raw.empty?

      raw.split(",").map { |font| font.strip }.reject(&:empty?)
    end

    def show_usage(exit_code: 0)
      puts <<~USAGE
        Usage:
          fifi install <fonts> [options]
          fifi download <fonts> [options]

        Examples:
          fifi install nunito
          fifi install nunito, inter, open sans
          fifi download nunito -o assets/fonts
          fifi download nunito

        Options:
          -s, --static    Prefer static fonts (default: variable)
          -h, --help      Show help
      USAGE
      exit_code
    end

    def help_flag?(arg)
      %w[-h --help help].include?(arg)
    end

    def default_font_dir
      if mac_platform?
        File.join(Dir.home, "Library", "Fonts")
      elsif windows_platform?
        base = ENV["LOCALAPPDATA"] || File.join(Dir.home, "AppData", "Local")
        File.join(base, "Microsoft", "Windows", "Fonts")
      else
        File.join(Dir.home, ".local", "share", "fonts")
      end
    end

    def mac_platform?
      /darwin/i.match?(RUBY_PLATFORM)
    end

    def windows_platform?
      /mswin|mingw|cygwin/i.match?(RUBY_PLATFORM)
    end

    def linux_platform?
      /linux/i.match?(RUBY_PLATFORM)
    end
  end
end
