require_relative 'links'

class QuestionLike
  def self.find(id)
    question_like_data = QuestionsDatabase.instance.execute.get_first_row(<<-SQL, id: id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      question_likes.id = :id
    SQL
    QuestionLike.new(question_likes_data)
  end
  
  def self.likers_for_question_id(question_id)
    users_data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes 
      ON
        users.id = question_likes.user_id
      WHERE 
        question_likes.question_id = :question_id
    SQL
    
    users_data.map {|user_data| User.new(user_data)}
  end
  
  def self.num_likes_for_question_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
      SELECT
        COUNT(*) AS likes
      FROM
        questions
      JOIN
        question_likes 
      ON
        questions.id = question_likes.question_id
      WHERE 
        question_likes.question_id = :question_id
        -- questions.id = :question_id
    SQL
    
  end
  
  def self.liked_questions_for_user_id(user_id)
    QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = :user_id
    SQL
    
    questions_data.map { |question_data| Question.new(question_data) }
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        question_likes
    SQL
    data.map { |datum| QuestionLike.new(datum) }
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, id: id, user_id: user_id, question_id: question_id)
        UPDATE
          question_likes
        SET 
          id = :id, user_id = :user_id, question_id = :question_id
        WHERE
          question_likes.id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, id: id, user_id: user_id, question_id: question_id)
      INSERT INTO
        question_likes (id, user_id, question_id)
      VALUES
        (:id, :user_id, :question_id)
      SQL
      @id = QuestionsDatabase.last_insert_row_id
    end
  end
  
  def delete
    QuestionsDatabase.instance.execute(<<-SQL, id: id)
      DELETE FROM
        question_likes
      WHERE
        question_likes.id = :id
    SQL
  end
  
  def self.most_liked_questions(n)
    questions_data = QuestionsDatabase.instance.execute(<<-SQL, limit: n)
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_likes
    ON
      questions.id = question_likes.question_id
    GROUP BY
      questions.id 
    ORDER BY  
      COUNT (*) DESC
    LIMIT
      :limit
    SQL
    
    questions_data.map {|question_data| Question.new(question_data)}
  end
  
  attr_accessor :user_id, :question_id
  attr_reader :id
  
  
  
  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end
end