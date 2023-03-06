const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_login = require('../modules/model/mod_login');
const mod_user = require('../modules/model/mod_user');

exports.postRegister = (req, callback) => {
    const _id = new ObjectId()
    const loginData = req.body
    const loginName = loginData['loginName'];
    const loginPass = loginData['loginPass'];
    const userNickName = loginData['userNickName'];
    var loginSchema = mongoose.model("login", mod_login);
    var userSchema = mongoose.model("user", mod_user);

    //判断用户名是否存在
    loginSchema.find({login_name: loginName},{login_name: 1},function(err,docs){
        if(!err){
            console.log(docs)
            if (docs.length > 0) {
                let resultData = {
                    data: {result: 'exist'}
                }
                callback(undefined, resultData);
            } else {
                loginSchema.create({
                    _id: _id,
                    login_name: loginName,
                    login_password: loginPass,
                },function(err){
                    if(!err){
                        console.log("插入成功")
                        userSchema.create({
                            _id: _id,
                            user_name: loginName,
                            user_nickname: userNickName
                        }, function(err) {
                            if(!err){
                                let resultData = {
                                    data: {result: 'success'}
                                }
                                callback(undefined, resultData);
                            }
                        })
                    } else {
                        let resultData = {
                            data: {result: 'failure'}
                        }
                        callback(undefined, resultData);
                    }
                })
            }
        }
    })
}