guard :rspec, all_on_start: false do
  # RSpec設定変更時は全テスト実行
  watch('spec/spec_helper.rb') { 'spec' }
  watch('spec/rails_helper.rb') { 'spec' }

  # Spec自身の変更
  watch(%r{^spec/.+_spec\.rb$})

  # Models
  watch(%r{^app/models/(.+)\.rb$}) do |m|
    "spec/models/#{m[1]}_spec.rb"
  end

  # Controllers
  watch(%r{^app/controllers/(.+)_controller\.rb$}) do |m|
    "spec/requests/#{m[1]}_spec.rb"
  end

  # Helpers
  watch(%r{^app/helpers/(.+)_helper\.rb$}) do |m|
    "spec/helpers/#{m[1]}_helper_spec.rb"
  end

  # Mailers
  watch(%r{^app/mailers/(.+)\.rb$}) do |m|
    "spec/mailers/#{m[1]}_spec.rb"
  end

  # Views変更時は関連Request Specを実行
  watch(%r{^app/views/(.+)/.+\.(erb|haml|slim)$}) do |m|
    "spec/requests/#{m[1]}_spec.rb"
  end

  # Routes変更時は全Request Spec実行
  watch('config/routes.rb') { 'spec/requests' }

  # FactoryBot
  watch(%r{^spec/factories/(.+)\.rb$}) { 'spec' }
end