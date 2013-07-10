Gem::Specification.new do |spec|
  spec.name              = "correspondence-markup"
  spec.version           = "0.2.0"
  spec.platform          = Gem::Platform::RUBY
  spec.authors           = ["Philip Dorrell"]
  spec.email             = ["http://thinkinghard.com/email.html"]
  spec.homepage          = "https://github.com/pdorrell/correspondence-markup"
  spec.summary           = "A markup language to generate 'Correspondence' HTML"
  spec.description       = "Use to generate HTML pages containing structure groups, structures and items as used by correspondence.js."
  spec.rubyforge_project = spec.name

  spec.required_rubygems_version = ">= 1.3.6"
  
  # If you have runtime dependencies, add them here
  # spec.add_runtime_dependency "other", "~> 1.2"
  
  # If you have development dependencies, add them here
  # spec.add_development_dependency "another", "= 0.9"

  # The list of files to be contained in the gem
  spec.files = Dir['lib/*.rb']
  spec.files += Dir['lib/**/*.rb']
  spec.files += Dir['lib/**/*.treetop']
  spec.files += ["LICENSE.txt", "Rakefile"]

  spec.executables   = []
  
  spec.require_paths = ['lib']
end
