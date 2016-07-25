#!/usr/bin/env ruby

# info sul file
get '/info/:filename/detail' do |filename|
    @db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    
    debug("db_file", @db_file)
    debug("empty?", @db_file.empty?)
    
    if !@db_file.empty? && File.exist?(@db_file[0][2])
        
        mimetype = @db_file[0][10]
        metadata = JSON.parse(@db_file[0][11])
        
        case mimetype
        when /(image)/i
            @data = "image"
        when /(audio)/i
            @data = """<ul>
<li><strong>Artista: </strong>#{metadata["artist"]}</li>
<li><strong>Titolo: </strong>#{metadata["title"]}</li>
<li><strong>Album: </strong>#{metadata["album"]}</li>
<li><strong>Durata: </strong>#{metadata["length"]}</li>
<li><strong>Bitrate: </strong>#{metadata["bitrate"]} kbps</li>
</ul>
<h3>Anteprima</h3>
<div align=\"center\"><audio controls>
<source src=\"/downloads/#{filename}\" type=\"#{mimetype}\">
Il tuo browser è vecchio e non supporta il tag audio. Aggiornati!
</audio></div>"""
        when /(video)/i
            @data = "video"
        else
            @data = "generic"
        end
        
        erb :info
    else
        redirect to ('/downloads') # vai ai downloads
    end
end
