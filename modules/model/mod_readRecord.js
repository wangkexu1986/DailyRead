const mongoose = require('mongoose')
const { ObjectId } = require('mongodb');

var Schema = mongoose.Schema;

var readRecordSchema = new Schema({
    _id: {type: ObjectId, description: "id"},
    essay_id: {type: String, description:"文章id"},
    read_record: {type: String, description:"跟读录音"},
    record_time:  {type: String, description:"跟读长度"},
    create_date: {type: Date, description:"创建时间"},
    update_date: {type: Date, description:"更新时间"},
    create_user: {type: String, description:"创建人"},
    update_user: {type: String, description:"更新人"},
})

module.exports = readRecordSchema;