require_relative 'links'

class Question
  def self.find(id)
    question_data = QuestionsDatabase.instance.instance.execute.get_first_row(<<-SQL, id: id)
    SELECT
      *
    FROM
      questions
    WHERE
      questions.id = :id
    SQL
    Question.new(question_data)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end
  
  def self.find_by_author_id(author_id)
    questions_data = QuestionsDatabase.instance.execute(<<-SQL, author_id: author_id)
      SELECT 
        *
      FROM 
        questions
      WHERE
        questions.author_id = :author_id
    SQL
    
    # questions_data.map { |question_data| Question.new(question_data) }
    p questions_data
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        questions
    SQL
    data.map { |datum| Question.new(datum) }
  end
  
  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL, attrs.merge({id: id}))
        UPDATE
          questions
        SET 
          title = :title, body = :body, author_id = :author_id
        WHERE
          questions.id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, attrs)
      INSERT INTO
        questions (title, body, author)
      VALUES
        (:title, :body, :author_id)
      SQL
      
      @id = QuestionsDatabase.last_insert_row_id
    end
  end
  
  def delete
    QuestionsDatabase.instance.execute(<<-SQL, id: id)
      DELETE FROM
        questions
      WHERE
        questions.id = :id
    SQL
  end
  
  def attrs
  { title: title, body: body, author_id: author_id }
  end
  
  attr_accessor :title, :body, :author_id
  attr_reader :id
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @author_id = options['author_id']
    @title = options['title']
  end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def replies
    Reply.find_by_question_id(id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(id)
  end
end