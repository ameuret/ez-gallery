#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# == hamlr - A HAML template expander
# ===Requirements
# * Ruby 1.8.4
# * Log4R 1.0.4
# * Haml
# ===TODO
# === COPYRIGHT
#
# (c) 2007 Arnaud Meuret
#
# $Id: vex.rb 843 2004-11-16 11:01:58Z arnaud $
#
require 'rubygems'
#require 'active_support'
require 'pp'
require 'optparse'
#require 'log4r'
require 'pathname'
require 'yaml'
require 'haml'

FAILURE_EXIT_CODE = 1
SUCCESS_EXIT_CODE = 0

"$Rev: 843 $" =~ /Rev: (\d+)/
VER = [0,0,$1.to_i]
TITLE = "hamlr - A HAML template expander"

verbose = false
outFileName = ""

#==========================================================

# Set the option parser up
options = OptionParser.new do |opts|	
  opts.banner = TITLE + " - " + VER.join(".") + "\n\nUsage: #{$0} options... | TEMPLATE_FILE [DATA_FILE]"

  opts.on("-o", "--output FILE", "Writes output to FILE instead of stdout.") { |oFN| outFileName = oFN }
  opts.on("-v", "--verbose", "Outputs debug log messages.") { |verbose| }
  opts.on_tail("--version", "Show version") { puts TITLE + " - " + VER.join(".") + "\nData file format v.#{SUPPORTED_FORMAT}";  exit SUCCESS_EXIT_CODE;}
  opts.on_tail("-h", "--help", "You are reading it, nothing more.") { puts opts; exit SUCCESS_EXIT_CODE;}
end

begin
  options.parse!
rescue OptionParser::InvalidOption
  $stderr.puts $!.message
  puts options
  exit FAILURE_EXIT_CODE
end
exit FAILURE_EXIT_CODE if ARGV.length < 1

#==========================================================

# Get a logger
# log = Log4r::Logger.new $0
# log.outputters = Log4r::Outputter.stderr
# log.level = verbose ? Log4r::DEBUG : Log4r::INFO # Standard levels are : DEBUG < INFO < WARN < ERROR < FATAL

#==========================================================

templateFileName = ARGV[0]
dataFileName = ARGV[1]
templateFile = File.open( templateFileName, "r" )

dataFile = File.open( dataFileName, "r" ) if ARGV.length > 1
output = case outFileName
         when ""
           puts "stdout"
           $stdout
         else
           File.open( outFileName, "w+" )
         end

if dataFile
  dSpace = YAML::load(dataFile)
  dataFile.close
end

def trackingCode( site )
  <<-EOS
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-3609486-1");
pageTracker._initData();
pageTracker._trackPageview();
</script>
  EOS
end

def title
  "Photographie • Solutions Graphiques • Impression"
end

def follow
  <<-EOS
<a href="https://twitter.com/dipascale" class="twitter-follow-button" data-show-count="false" data-lang="fr" data-width="130px">Suivre @dipascale</a>
<script src="//platform.twitter.com/widgets.js" type="text/javascript"></script>
  EOS
end

ham = Haml::Engine.new( templateFile.read )

output.print ham.render( nil, { :ds => dSpace } )

output.close
templateFile.close

