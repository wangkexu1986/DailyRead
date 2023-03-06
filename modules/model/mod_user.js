const mongoose = require('mongoose')
const { ObjectId } = require('mongodb');

var Schema = mongoose.Schema;

var userSchema = new Schema({
    _id: {type: ObjectId, description: "id"},
    user_name: {type: String, description: "注册名"},
    user_nickname: {type: String, description: "用户昵称（显示名）"},
})

module.exports = userSchema;