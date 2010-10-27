# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hyper_record}
  s.version = "0.9.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["tylerkovacs"]
  s.date = %q{2010-10-27}
  s.description = %q{See README}
  s.email = %q{tyler.kovacs@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "HOW_TO_RUN_TESTS",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION.yml",
     "benchmark/save.rb",
     "hyper_record.gemspec",
     "init.rb",
     "lib/active_record/connection_adapters/hyper_table_definition.rb",
     "lib/active_record/connection_adapters/hypertable_adapter.rb",
     "lib/active_record/connection_adapters/qualified_column.rb",
     "lib/associations/hyper_has_and_belongs_to_many_association_extension.rb",
     "lib/associations/hyper_has_many_association_extension.rb",
     "lib/hyper_record.rb",
     "lib/hypertable/gen-rb/client_constants.rb",
     "lib/hypertable/gen-rb/client_service.rb",
     "lib/hypertable/gen-rb/client_types.rb",
     "lib/hypertable/gen-rb/hql_constants.rb",
     "lib/hypertable/gen-rb/hql_service.rb",
     "lib/hypertable/gen-rb/hql_types.rb",
     "lib/hypertable/thrift_client.rb",
     "lib/hypertable/thrift_transport_monkey_patch.rb",
     "pkg/hyper_record-0.9.3.gem",
     "spec/fixtures/pages.yml",
     "spec/fixtures/qualified_pages.yml",
     "spec/lib/associations_spec.rb",
     "spec/lib/hyper_record_spec.rb",
     "spec/lib/hypertable_adapter_spec.rb",
     "spec/spec_helper.rb",
     "test/test_helper.rb",
     "test/thrift_client_test.rb"
  ]
  s.homepage = %q{http://github.com/tylerkovacs/hyper_record}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Fully integrates ActiveRecord with Hypertable.}
  s.test_files = [
    "spec/lib/associations_spec.rb",
     "spec/lib/hypertable_adapter_spec.rb",
     "spec/lib/hyper_record_spec.rb",
     "spec/spec_helper.rb",
     "test/thrift_client_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
