const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_readRecord = require('./model/mod_readRecord');
const mod_user = require('./model/mod_user');
var fs = require('fs');
const path = require('path');

exports.getReadRecordList = (req, callback) => {
    const pageSize = 20
    const readRecordData = req.query
    const essayId = readRecordData['essayId'];
    const page = readRecordData['pageNumber'];

    var readRecordSchema = mongoose.model("read_record", mod_readRecord);
    var userSchema = mongoose.model("user", mod_user);
    readRecordSchema.find({essay_id: essayId}, {_id: 1, read_record: 1, update_user: 1, update_date: 1, record_time: 1}, {skip: (page - 1) * pageSize, limit: pageSize}, function(err, docs){
        if(!err){
            console.log(docs);
            var models = []
            for (let i = 0; i<docs.length; i++) {
                let model = docs[i];
                let userId = model.update_user;
                let date = model.update_date;
                let year = date.getFullYear();
                let month = date.getMonth();
                let day = date.getDate();
                let hour = date.getHours();
                let minute = date.getMinutes();
                let dateString = year + '/' + month + '/' + day + " " + hour + ':' + minute;
                userSchema.find({_id: model.update_user}, {user_nickname: 1}, function(err,userDocs) {
                    let userModel = userDocs[0]
                    let nickName = userModel["user_nickname"];
                    
                    var newModel = {_id: model._id,'user_id': userId, 'user': nickName, 'date': dateString, 'read_record': model.read_record, 'record_time': model.record_time, 'update_date': date};
                    models.push(newModel)
                    if (models.length == docs.length) {
                        let resultData = {'data': models}
                        callback(undefined, resultData);
                    }
                })
            }
        } else {
            callback(err);
        }
    })
}

exports.downloadRecord = (req, callback) => {
    const essayData = req.query
    const fileName = essayData["fileName"]

    const filePath = path.join(
        __dirname,
        "../upload",
        fileName
      );
        callback(undefined, filePath)
}