const mongoose = require('mongoose')
const { ObjectId } = require('mongodb');

var Schema = mongoose.Schema;

var loginSchema = new Schema({
    _id: {type: ObjectId, description: "id"},
    login_name: {type: String, description: "注册名"},
    login_password: {type: String, description: "登陆密码"},
})

module.exports = loginSchema;