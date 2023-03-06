let createError = require('http-errors');
let express = require('express');
let path = require('path');
let cookieParser = require('cookie-parser');
let logger = require('morgan');

let indexRouter = require('./routes/index');
let homeRouter = require('./routes/home');
let loginRouter = require('./routes/login');
let registerRouter = require('./routes/register');
let createEssayRouter = require('./routes/createEssay');
let getEssayRouter = require('./routes/getEssay');
let createReadRecordRouter = require('./routes/createReadRecord')
let getReadRecordRouter = require('./routes/getReadRecord')

let mongoose = require('mongoose')
mongoose.connect('mongodb://127.0.0.1:27017/DailyRead')

const conn = mongoose.connection;
conn.on('error', function(error){
  console.log('数据库连接失败：'+error);
});
conn.once('open', function() {
  console.log('数据库连接成功');
});

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(express.json())

var bodyParser = require('body-parser');
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/', homeRouter);
app.use('/', loginRouter);
app.use('/', registerRouter);
app.use('/', createEssayRouter);
app.use('/', getEssayRouter);
app.use('/', createReadRecordRouter);
app.use('/', getReadRecordRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
