require_relative 'links'

class QuestionFollow
  def self.find(id)
    question_follow_data = QuestionsDatabase.instance.execute.get_first_row(<<-SQL, id: id)
    SELECT
      *
    FROM
      question_follows
    WHERE
      question_follows.id = :id
    SQL
    QuestionFollow.new(question_follows_data)
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        question_follows
    SQL
    data.map { |datum| QuestionFollow.new(datum) }
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, id: id, user_id: user_id, question_id: question_id)
        UPDATE
          question_follows
        SET 
          id = :id, user_id = :user_id, question_id = :question_id
        WHERE
          question_follows.id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, id: id, user_id: user_id, question_id: question_id)
      INSERT INTO
        question_follows (id, user_id, question_id)
      VALUES
        (:id, :user_id, :question_id)
      SQL
      @id = QuestionsDatabase.last_insert_row_id
    end
  end
  
  def delete
    QuestionsDatabase.instance.execute(<<-SQL, id: id)
      DELETE FROM
        question_follows
      WHERE
        question_follows.id = :id
    SQL
  end
  
  def self.followers_for_question_id(question_id)
    users_data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
        WHERE 
        question_follows.question_id = :question_id
    SQL
    
    users_data.map { |user_data| User.new(user_data) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    users_data = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE 
        question_follows.user_id = :user_id
    SQL
    
    users_data.map { |user_data| User.new(user_data) }
  end
  
  def self.most_followed_questions(n)
    questions_data = QuestionsDatabase.instance.execute(<<-SQL, limit: n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows
      ON
        questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        :limit
    SQL
    
    questions_data.map { |question_data| Question.new(question_data)}
  end
  
  attr_accessor :user_id, :question_id
  attr_reader :id
  
  
  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end
end