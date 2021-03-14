import os
from flask import Flask
from flask_login import LoginManager, UserMixin, current_user, login_user, login_required, logout_user, login_manager
from flask import Flask, render_template, redirect, url_for, request, g, session
from flask_sqlalchemy import SQLAlchemy
import re

# set up project directory
project_dir = os.path.dirname(os.path.abspath(__file__))
database_file = "sqlite:///{}".format(os.path.join(project_dir, "database.db"))

# Set up flask app
main = Flask(__name__, template_folder='./templates', static_folder='./static')
main.config["SQLALCHEMY_DATABASE_URI"] = database_file
main.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(main)

# Set up app and Flask-Login for them to work together
main.secret_key = "jackie trang" # required a secret key for session authentication
signin = LoginManager() #built-in class LoginManager()
signin.init_app(main)  # configure app for login
signin.login_view = 'signin'


# Intialize Task and User objects
class Task(db.Model):
    '''
    Task has foreign key link to User table
    '''
    __tablename__ = 'Task'
    id = db.Column(db.Integer,primary_key=True)
    title = db.Column(db.String(100), nullable=True, unique=True, primary_key=True)
    status = db.Column(db.String(100), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('User.id'))



class User(UserMixin, db.Model):
    __tablename__ = 'User'
    id = db.Column(db.Integer, primary_key=True)
    user_email = db.Column(db.String(100))
    password = db.Column(db.String(100))
    task_id = db.relationship('Task', backref='User')

# Creates database for users and tasks
db.create_all()
# Generates entries for the database
db.session.commit()

@main.route('/', methods=['GET', 'POST'])
def default():
    '''
    By default, users are routed to log in page
    '''
    return redirect('signin')


@signin.user_loader
def load_user(id):
    '''
    This sets the callback for reloading a user from the session. 
    The function you set should take a user ID (a unicode)
     and return a user object, or None if the user does not exist.
    '''
    return User.query.get(int(id))

@main.before_request
def before_request():
    '''
    Set g.user to current_user before running any requests
    '''
    g.user = current_user


@main.route('/signup', methods=['GET','POST'])
def signup():
    '''
    Sign up new users with password requirements
    - POST request: Save user sign-up information to db and redirect them to log-in page
    - GET request: render sign-up page
    '''
    if request.method == 'POST':
        # Checks password requirements
        password = request.form.get('password')
        # password needs at least 1 number
        if re.search('[0-9]', password) is None:
            error_msg = "Password needs at least one number"
            return render_template("signup.html", error=error_msg)
        # password needs at least 1 letter
        elif re.search('[a-z]', password) is None:
            error_msg = "Password needs at least one letter"
            return render_template("signup.html", error=error_msg)
        # password and re-entered password match
        if password != request.form['repeat']:
            error_msg = "Password doesn't match"
            return render_template("signup.html", error=error_msg)
        user_email = request.form.get('user_email')
        signup_user = User(user_email=user_email, password=password) # new instance of user
        # add user login + password to db
        db.session.add(signup_user)
        db.session.commit()
        return redirect("/signin")

    elif request.method == 'GET':
        return render_template('signup.html')



@main.route('/signin', methods=['GET', 'POST'])
def signin():
    ''' 
    Log in existing user based on their user email and password.
    '''
    if request.method == 'POST':
        user_email = request.form.get('user_email')
        password = request.form.get('password')
        user = User.query.filter_by(user_email=user_email, password=password).first() #query user
        if user: # if there's user info in db, log them in
            login_user(user)
            return redirect("/main") # go to index.html

    elif request.method == 'GET':
        return render_template('signin.html')



@main.route('/main', methods=["GET", "POST"])
@login_required
def index():
    '''
    Query all added tasks and put them to render context of index.html
    '''
    g.user = current_user
    tasks = Task.query.filter_by(user_id=g.user.id).all() # all tasks
    todo = Task.query.filter_by(status='todo',user_id=g.user.id).all() # to do tasks
    doing = Task.query.filter_by(status='doing',user_id=g.user.id).all() # doing tasks
    done = Task.query.filter_by(status='done',user_id=g.user.id).all() #done tasks
    return render_template("index.html", tasks=tasks, todo=todo, doing=doing, done=done, user=current_user)

@main.route('/add', methods=['POST'])
@login_required
def add():
    '''
    Add new task to either To do - Doing - Done board
    '''
    if request.form:
        existed_tasks = [task.title for task in Task.query.all()]
        # only add unique tasks to the board
        if request.form.get("title") not in existed_tasks:
            title = request.form.get("title") # get task title
            status = request.form.get("status") # get task status
            task = Task(id = 1, title= title, status=status, user_id = g.user.id) #task instance
            # save that task to db
            db.session.add(task)
            db.session.commit()
    return redirect('/main')

@main.route("/update", methods=["POST"])
def update():
    '''
    Move tasks to other boards, possible directions:
        - Move from To Do to Doing
        - Move from Doing to Done
        - Move from Done back to Doing
    '''
    task_name = request.form.get("task_name") # get the task title
    move_to_status = request.form.get("move_to_status") # get the status of the board we want to move that task to
    task = Task.query.filter_by(title=task_name).first() # query the task based on name and status
    task.status = move_to_status # change status -> change board
    db.session.commit() # save change to database
    return redirect("/main") 

@main.route("/delete", methods=["POST"])
def delete():
    '''
    Delete tasks
    '''
    task_delete = request.form.get("task_delete") # get task title
    task = Task.query.filter_by(title=task_delete).first() # query the task based on title
    db.session.delete(task) # delete that task from the database
    db.session.commit()
    return redirect("/main")

if __name__ == "__main__":
    main.run(debug=True)
