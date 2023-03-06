const mongoose = require('mongoose');
const mod_essay = require('../modules/model/mod_essay');
const mod_user = require('../modules/model/mod_user');

exports.getHomeList = (req, res, callback) => {
    const pageSize = 20
    const homeData = req.query
    const page = homeData['pageNumber'];
    const userId = homeData['userId'];
    var user = {}
    if (userId != null) {
        user = {create_user: userId}
    }
    var userSchema = mongoose.model("user", mod_user);
    var essaySchema = mongoose.model("essay", mod_essay);
    essaySchema.find(user,{_id: 1,　essay_title: 1, essay_content: 1, update_date: 1, update_user: 1}, {skip: (page - 1) * pageSize, limit: pageSize},function(err,docs) {
        if(!err){
            console.log(docs);
            var models = []
            for (let i = 0; i<docs.length; i++) {
                let model = docs[i];
                let date = model.update_date;
                let year = date.getFullYear();
                let month = date.getMonth();
                let day = date.getDate();
                let dateString = year + '.' + month + '.' + day;
                userSchema.find({_id: model.update_user}, {_id: 1, user_nickname: 1}, function(err,userDocs) {
                    let userModel = userDocs[0]
                    let nickName = userModel["user_nickname"];
                    var newModel = {'_id': model._id, 'essay_title': model.essay_title, 'essay_content': model.essay_content, 'writter': nickName,'date': dateString, 'update_date': model.update_date};
                    models.push(newModel)
                    if (models.length == docs.length) {
                        models.sort((a, b)=>{
                            a.update_date > b.update_date
                        })
                        let resultData = {'data': models}
                        callback(undefined, resultData);
                    }
                })
            }
        } else {
            callback(err, [])
        }
    })
}