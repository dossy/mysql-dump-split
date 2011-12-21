#!/usr/bin/ruby
 
if ARGV.length == 1
    dumpfile = ARGV.shift
else
    puts("Please specify a dumpfile to process")
    exit 1
end
 
STDOUT.sync = true
 
class Numeric
    def bytes_to_human
        units = %w{B KB MB GB TB}
        e = (self == 0) ? 0 : (Math.log(self)/Math.log(1024)).floor
        s = "%.3f" % (to_f / 1024**e)
        s.sub(/\.?0*$/, units[e])
    end
end


if File.exist?(dumpfile)
    d = File.new(dumpfile, "r")
 
    db = ""
    table = "preamble"
    outfile = File.new("#{db}_#{table}.sql", "w")
    linecount = tablecount = starttime = 0
 
    while (line = d.gets)
        if line =~ /^-- Table structure for table .(.+)./
            table = $1
            linecount = 0
            tablecount += 1
 
            puts("\n\n") if outfile
 
            puts("Found a new table: #{table}")
 
            starttime = Time.now
            outfile = File.new("#{db}_#{table}.sql", "w")
        elsif line =~ /^USE .(.+).;/ || line =~ /^-- Host: .+    Database: (.+)$/
            db = $1
            puts("Found a new db: #{db}")
        end
 
        if table != "" && outfile
            outfile.syswrite line
            linecount += 1
            elapsed = Time.now.to_i - starttime.to_i + 1
            print("    writing line: #{linecount} #{outfile.stat.size.bytes_to_human} in #{elapsed} seconds #{(outfile.stat.size / elapsed).bytes_to_human}/sec                 \r")
        end
    end
end
 
puts
