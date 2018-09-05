require_relative 'links'

class User
  def self.find(id)
    user_data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT
      *
    FROM
      users
    WHERE
      users.id = :id
    SQL
    User.new(user_data)
  end
  
  def self.find_by_id(id)
    user_data = QuestionsDatabase.get_first_row(<<-SQL, id: id)
      SELECT
        users.*
      FROM
        users
      WHERE
        users.id = :id
    SQL

    user_data.nil? ? nil : User.new(user_data)
  end
  
  def self.find_by_name(fname, lname)
    user_data = QuestionsDatabase.instance.execute.get_first_row(<<-SQL, fname: fname, lname: lname)
    SELECT
      *
    FROM
      users
    WHERE
      users.fname = :fname, users.lname = :lname
    SQL
    User.new(user_data)
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
    SQL
    data.map { |datum| User.new(datum) }
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, id: id, fname: fname, lname: lname)
        UPDATE
          users
        SET 
          fname = :fname, lname = :lname
        WHERE
          users.id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname: fname, lname: lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (:fname, :lname)
      SQL
      
      @id = QuestionsDatabase.last_insert_row_id
    end
  end
  
  def delete
    QuestionsDatabase.instance.execute(<<-SQL, id: id)
      DELETE FROM
        users
      WHERE
        users.id = :id
    SQL
  end
  
  attr_accessor :fname, :lname
  attr_reader :id
  
  
  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end
  
  def average_karma
    QuestionsDatabase.instance.execute(<<-SQL, author_id: self.id)
      SELECT
        CAST(COUNT(question_likes.id) AS FLOAT) /
          COUNT(DISTINCT(questions.id)) AS avg_karma
      FROM
        questions
      LEFT JOIN
        questions_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        users.id = :id
    SQL
  end
  
  def authored_questions
    Question.find_by_author_id(id)
  end
  
  def authored_replies
    Reply.find_by_user_id(id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end
end