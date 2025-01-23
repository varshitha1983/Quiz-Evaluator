%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//external declarations
extern FILE *yyin;//takes input from quiz_iput.txt and send it to the lexer
int yylex(void);//Generates the tokens 
void yyerror(const char *s);//Handles errors during parsing
void evaluate_answer(char *user_answer, char *correct_answer, int points, int is_numeric);//Evaluates the answer given by user

int score = 0;
int difficulty_threshold = 1;

//Used for printing options for mcq options
typedef struct {
    char *option[4];  // Store up to 4 options
    int count;        // Track the number of options
} OptionList;

OptionList current_options;  // Holds options for the current MCQ question

%}

//Defines types of data
%union {
    char *str;
    int num;
}

//Token declarations
%token QUIZ QUESTION TYPE OPTIONS CORRECT THRESHOLD//for questions
%token TRUE_FALSE MCQ NUMERIC FILL_IN_BLANK//for question type
%token <str> STRING
%token <num> NUMBER

//Type declarations
%type <num> question_type
%type <str> answer
%type <str> options

//Grammar rules 
%%

quiz            : QUIZ STRING THRESHOLD NUMBER question_list {
                    difficulty_threshold = $4;
                    printf("Quiz: %s, Difficulty Threshold: %d\n", $2, difficulty_threshold);
                }
                ;

question_list   : question_list question
                | question
                ;
//rule for question
question        : QUESTION STRING TYPE question_type options CORRECT answer {
                    // Print question type
                    switch ($4) {
                        case 1:
                            printf("\nQuestion Type: TRUE/FALSE\n");
                            break;
                        case 2:
                            printf("\nQuestion Type: MCQ\n");
                            break;
                        case 3:
                            printf("\nQuestion Type: NUMERIC\n");
                            break;
                        case 4:
                            printf("\nQuestion Type: FILL IN THE BLANK\n");
                            break;
                    }

                    // Print question
                    printf("Question: %s\n", $2);

                    // Display options for MCQ
                    if ($4 == 2) {  
                        printf("Options:\n");
                        for (int i = 0; i < current_options.count; i++) {
                            printf("%d. %s\n", i + 1, current_options.option[i]);
                        }
                    }

                    // Get user input and evaluate
                    char user_answer[50];
                    printf("Your Answer: ");
                    scanf("%s", user_answer);
                    evaluate_answer(user_answer, $7, $4, ($4 == 3));  // Pass is_numeric flag for NUMERIC type
                }
                ;

question_type   : TRUE_FALSE              { $$ = 1; /* Easy */ }
                | MCQ                     { $$ = 2; /* Medium */ }
                | NUMERIC                 { $$ = 3; /* Hard */ }
                | FILL_IN_BLANK           { $$ = 4; /* Medium */ }
                ;

options         : OPTIONS STRING STRING STRING STRING {
                    current_options.count = 4;
                    current_options.option[0] = $2;
                    current_options.option[1] = $3;
                    current_options.option[2] = $4;
                    current_options.option[3] = $5;
                }
                | /* Empty */ { current_options.count = 0; /* Optional for non-MCQ types */ }
                ;

answer          : STRING                  { $$ = $1; }
                | NUMBER                  {
                    char buffer[20];
                    sprintf(buffer, "%d", $1);
                    $$ = strdup(buffer);
                }
                ;

%%

void evaluate_answer(char *user_answer, char *correct_answer, int points, int is_numeric) {
    if (is_numeric) {
        // Normalize numeric input and correct answer for comparison
        int user_value = atoi(user_answer);
        int correct_value = atoi(correct_answer);

        if (user_value == correct_value) {
            score += points;
            printf("Correct! You earned %d points.\n", points);
        } else {
            printf("Incorrect. Correct answer is: %s\n", correct_answer);
        }
    } else {
        if (strcasecmp(user_answer, correct_answer) == 0) {
            score += points;
            printf("Correct! You earned %d points.\n", points);
        } else {
            printf("Incorrect. Correct answer is: %s\n", correct_answer);
            printf("Tip: Focus more on this type of question.\n");
        }
    }

    if (points >= difficulty_threshold && score == 0) {
        printf("Tip: Focus more on this type of question.\n");
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    FILE *file = fopen("quiz_input.txt", "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;

    printf("Welcome to the Personalized Quiz Evaluator!\n");

    if (yyparse() == 0) {
        printf("\nQuiz parsed successfully!\n");
    } else {
        printf("\nError parsing the quiz file.\n");
        fclose(file);
        return 1;
    }

    fclose(file);

    printf("Final score: %d\n", score);
    return 0;
}
