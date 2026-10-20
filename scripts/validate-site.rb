require 'yaml'

home = File.read('_site/index.html')
publications = File.read('_site/publications/index.html')
documents = Dir['_publications/*.md'].map do |path|
  front_matter = File.read(path).split('---', 3)[1]
  YAML.safe_load(front_matter)
end

abort 'Expected exactly six publications' unless documents.length == 6

required_sections = [
  'About', 'Research and Skills', 'Academic Background',
  'Research Experience', 'Publications', 'Honors', 'Contact'
]
required_sections.each do |section|
  abort "Missing homepage section: #{section}" unless home.include?(section)
end

required_details = [
  'Junteng Liu', 'Junxian He', 'Zhiyuan Honor Scholarship',
  'MINIMAX', 'Tencent WXG', 'Shanghai AI Lab', 'Zifei Shan', 'Yu Cheng',
  'jliugi@connect.ust.hk', 'Vicent0205', 'junteng88716710', 'tbK9jl4AAAAJ'
]
required_details.each do |detail|
  abort "Missing homepage detail: #{detail}" unless home.include?(detail)
end

documents.each do |document|
  [home, publications].each do |listing|
    abort "Missing publication: #{document['title']}" unless listing.include?(document['title'])
    abort "Missing publication authors: #{document['title']}" unless listing.include?(document['authors'])
    abort "Missing publication year: #{document['title']}" unless listing.include?(document['year'].to_s)
  end
  path = document['permalink'].sub(%r{^/}, '').sub(%r{/$}, '')
  detail_page = File.read(File.join('_site', path, 'index.html'))
  abort "Missing publication details: #{document['title']}" unless detail_page.include?(document['authors'])
end

[home, publications].each do |page|
  count = page.scan('archive__item-title').length
  abort "Expected six publication entries, found #{count}" unless count == 6
end

placeholders = ['Your Name', 'Your Sidebar Name', 'none@example.org', 'Paper Title Number', 'Red Brick University']
[home, publications].each do |page|
  placeholders.each { |text| abort "Unreplaced template content: #{text}" if page.include?(text) }
  abort 'Unrendered Liquid markup' if page.match?(/\{\{|\{%/) 
end

Dir['_site/**/*.html'].each do |file|
  File.read(file).scan(/href="([^"]+)"/).flatten.each do |href|
    path = href.split(/[?#]/, 2).first
    next unless path.start_with?('/LJT-Homepage/') || path == '/LJT-Homepage'
    local = path.delete_prefix('/LJT-Homepage')
    candidates = [local, "#{local}/index.html", "#{local}.html"]
    exists = candidates.any? do |candidate|
      File.file?(File.join('_site', candidate)) || File.directory?(File.join('_site', candidate))
    end
    abort "Broken local link in #{file}: #{href}" unless exists
  end
end

puts 'Validated the homepage, all six publications, contact details, and local links.'
