module MyModule::QuizBuilder {
    use aptos_framework::signer;
    use std::vector;
    use std::string::String;

    /// Struct representing a quiz created by a teacher
    struct Quiz has store, key {
        questions: vector<String>,     // List of quiz questions
        correct_answers: vector<u8>,   // Correct answers (0, 1, 2, 3 for A, B, C, D)
        total_submissions: u64,        // Number of students who submitted
        passing_score: u8,             // Minimum score required to pass (out of total questions)
    }

    /// Struct to store student's quiz submission
    struct StudentSubmission has store, key {
        answers: vector<u8>,           // Student's answers (0, 1, 2, 3 for A, B, C, D)
        score: u8,                     // Final score achieved
        has_passed: bool,              // Whether student passed the quiz
    }

    /// Function for teachers to create a new quiz
    public fun create_quiz(
        teacher: &signer, 
        questions: vector<String>, 
        correct_answers: vector<u8>, 
        passing_score: u8
    ) {
        let quiz = Quiz {
            questions,
            correct_answers,
            total_submissions: 0,
            passing_score,
        };
        move_to(teacher, quiz);
    }

    /// Function for students to submit quiz answers
    public fun submit_quiz(
        student: &signer, 
        teacher_address: address, 
        answers: vector<u8>
    ) acquires Quiz {
        let quiz = borrow_global_mut<Quiz>(teacher_address);
        
        // Calculate score by comparing answers
        let score = 0;
        let i = 0;
        let total_questions = vector::length(&quiz.correct_answers);
        
        while (i < total_questions) {
            if (*vector::borrow(&answers, i) == *vector::borrow(&quiz.correct_answers, i)) {
                score = score + 1;
            };
            i = i + 1;
        };

        // Determine if student passed
        let has_passed = score >= quiz.passing_score;
        
        // Update quiz submission count
        quiz.total_submissions = quiz.total_submissions + 1;

        // Store student's submission
        let submission = StudentSubmission {
            answers,
            score,
            has_passed,
        };
        move_to(student, submission);
    }
}