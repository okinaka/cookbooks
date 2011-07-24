actions :install, :update, :default => :install

attribute :from_source, :default => false
attribute :force, :default => false
attribute :exists, :default => false
attribute :name, :kind_of => String
attribute :version, :default => '', :kind_of => String
attribute :exact_version, :default => false
attribute :release_version, :kind_of => String
attribute :cwd, :kind_of => String


