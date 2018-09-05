require_relative 'links'

class Reply
  def self.find(id)
    reply_data = QuestionsDatabase.instance.execute.get_first_row(<<-SQL, id: id)
    SELECT
      *
    FROM
      replies
    WHERE
      replies.id = :id
    SQL
    Reply.new(reply_data)
  end
  
  def self.find_by_user_id(user_id)
    QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = :user_id
    SQL
  end
  
  def self.find_by_user_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = :question_id
    SQL
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
    SQL
    data.map { |datum| Reply.new(datum) }
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, id: id, author_id: author_id, question_id: question_id, body: body)
        UPDATE
          replies
        SET 
          id = :id, author_id = :author_id, question_id = :question_id, body = :body
        WHERE
          replies.id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, id: id, author_id: author_id, question_id: question_id, body: body)
      INSERT INTO
        question_follows (id, author_id, question_id, body)
      VALUES
        :id, :author_id, :question_id, :body
      SQL
      @id = QuestionsDatabase.last_insert_row_id
    end
  end
  
  def delete
    QuestionsDatabase.instance.execute(<<-SQL, id: id)
      DELETE FROM
        replies
      WHERE
        replies.id = :id
    SQL
  end
  
  def self.find_by_question_id(question_id)
  replies_data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
    SELECT
      replies.*
    FROM
      replies
    WHERE
      replies.question_id = :question_id
  SQL

  replies_data.map { |reply_data| Reply.new(reply_data) }
end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def question
    Question.find_by_author_id(@author_id)
  end
  # 
  # def parent_reply
  # 
  # end
  
  # def child reply
  # 
  # end
  
  attr_accessor :author_id, :question_id, :body
  attr_reader :id
  
  
  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @author_id = options["author_id"]
    @body = options["body"]
  end
end