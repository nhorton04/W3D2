require 'sqlite3'
require 'singleton'
# require 'model_base'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('import.db')
    self.results_as_hash = true
  end
  
  def self.get_first_row(*args)
    instance.get_first_row(*args)
  end
  
  # def execute(*args)
  #   instance.execute(*args)
  # end
end
