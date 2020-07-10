var start = document.getElementById("start");
var quiz = document.getElementById("quiz");
var question = document.getElementById("question");
var qImg = document.getElementById("qImg");
var choiceA = document.getElementById("A");
var choiceB = document.getElementById("B");
var choiceC = document.getElementById("C");
var choiceD = document.getElementById("D");

var counter = document.getElementById("counter");
var timeGauge = document.getElementById("timeGauge");
var progress = document.getElementById("progress");
var scoreDiv = document.getElementById("scoreContainer");

var questions = [
    {

        question: "She is considered the 1st programmer by explaining how a specific engine could transition calculation to computation",

        imgSrc : "https://cdn.glitch.com/b34f70e3-6c66-4d44-821c-5e0bf97f0f00%2Fada%20lovelace.jpg?v=1593391461125",

        choiceA : "Ada Lovelace",

        choiceB : "Grace Hopper",

        choiceC : "Mary Keller",
      
        choiceD: "Michelle Obama",

        correct : "A"
    }, {
      question: "A famous women in computing conference is named after her",

        imgSrc : "https://cdn.glitch.com/b34f70e3-6c66-4d44-821c-5e0bf97f0f00%2Fgrace%20hopper.jpg?v=1593391461360",

        choiceA : "Susan Trinh",

        choiceB : "Jane Juan",

        choiceC : "Grace Hopper",
      
        choiceD: "Ginni Rometty",

        correct : "C"
    }, {
        question: "She developed and implemented code which led to the development of the battery’s used in hybrid cars",

        imgSrc : "https://cdn.glitch.com/b34f70e3-6c66-4d44-821c-5e0bf97f0f00%2Fannie%20hybrid.jpg?v=1593391461238",

        choiceA : "Grace Hopper",

        choiceB : "Annie Easley",

        choiceC : "Betsy Ancker",
      
        choiceD: "Katherine Johnson",

        correct : "B"
    },{
      question: "She is the first woman and Asian elected as a Texas Instruments Senior Fellow",
      imgSrc : "https://cdn.glitch.com/b34f70e3-6c66-4d44-821c-5e0bf97f0f00%2FDuy-Loan%20Le.jpg?v=1593393028229",

        choiceA : "Andrea Yang",
        choiceB : "Mary Jane",
        choiceC : "Duy-Loan Le", 
        choiceD: "Huyen Nguyen",

        correct : "C"
    }, {
      question: "She is an actress and inventor who pioneered the technology that formed the basis for today's WiFi, GPS, and Bluetooth communication systems",
      imgSrc : "https://cdn.glitch.com/b34f70e3-6c66-4d44-821c-5e0bf97f0f00%2Fhedy%20lamarr.jpg?v=1593393028359",

        choiceA : "Hedy Lamarr",
        choiceB : "Carly Fiorina",
        choiceC : "Lynn Conway", 
        choiceD: "Jacqueline Henry",

        correct : "A"
    }
  ]

var lastQuetion = questions.length - 1;
var runningQuestion = 0;
var count = 30;
var questionTime = 30; //30s 
var gaugeWidth = 150;
var gaugeUnit = gaugeWidth / questionTime;

var TIMER;
var score = 0;

// iterate through questions
function iterateQuestions(){
    var q = questions[runningQuestion];
    
    question.innerHTML = "<p>" + q.question + "</p>";
    qImg.innerHTML = "<img src="+ q.imgSrc +">";
    choiceA.innerHTML = q.choiceA;
    choiceB.innerHTML = q.choiceB;
    choiceC.innerHTML = q.choiceC;
    choiceD.innerHTML = q.choiceD;
}

start.addEventListener("click", startQuiz);

//start quiz
function startQuiz(){
    // to not show Start Game when the questions arrive
    start.style.display = "none";
    iterateQuestions()
    quiz.style.display = "block";
    renderProgress();
    renderCounter();
    TIMER = setInterval(renderCounter, 1000); // 1000ms = 1s
}

// render progress
function renderProgress(){
    for (var qIndex = 0; qIndex <= lastQuetion; qIndex++){
        progress.innerHTML += "<div class='prog' id=" + qIndex +"></div>";
    }
}

// counter render

function renderCounter(){
    if(count <= questionTime){
        counter.innerHTML = count;
        timeGauge.style.width = count * gaugeUnit + "px";
//       count backward
        count= count -1
    }else{
      clearInterval(TIMER);
      scoreRender;
      }
    }

function checkAnswer(answer) {
    if(answer == questions[runningQuestion].correct){
        score ++
        //change progress color to green
        answerIsCorrect();
    } else{
        //answer is wrong
        //change progress color to red
        answerIsWrong();
    }
    
    if(runningQuestion < lastQuetion){
        runningQuestion++;
        iterateQuestions();
    } else{
        //end the quiz and show the score
        clearInterval(TIMER);
        scoreRender();
    }
}

function answerIsCorrect(){
    document.getElementById(runningQuestion).style.background = "green";
}

function answerIsWrong(){
    document.getElementById(runningQuestion).style.background = "red";
}

//score render
function scoreRender(){
    scoreDiv.style.display = "block";

    //calculate the amount of question percent answered by the user
    var scorePerCent = Math.round(100* score/questions.length);

    //choose the image based on the scorePercent
    // let img = (scorePerCent >= 80) ? "":
    //             (scorePerCent >= 80) ? "assets/5.png":
    //             (scorePerCent >= 60) ? "assets/4.png":
    //             (scorePerCent >= 40) ? "assets/3.png":
    //             (scorePerCent >= 20) ? "assets/3.png":
    //             "assets/1.png";

    scoreDiv.innerHTML = "<p>"+ scorePerCent +"%</p>";

}