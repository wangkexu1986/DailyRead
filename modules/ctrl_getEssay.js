const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_essay = require('../modules/model/mod_essay');
var fs = require('fs');
const path = require('path');

exports.getEssay = (req, callback) => {
    const essayData = req.query
    const _id = essayData['_id'];

    var essaySchema = mongoose.model("essay", mod_essay);
    essaySchema.find({_id: _id}, function(err, docs){
        if(!err){
            console.log(docs);
            let data = {'data': docs}
            callback(undefined, data);
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