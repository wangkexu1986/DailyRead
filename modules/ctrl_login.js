const { ObjectId } = require('mongodb');
const mongoose = require('mongoose');
const mod_login = require('../modules/model/mod_login');
const mod_user = require('../modules/model/mod_user');

exports.postLogin = (req, callback) => {
    const loginData = req.body
    const loginName = loginData['loginName'];
    const loginPass = loginData['loginPass'];
    var loginSchema = mongoose.model("login", mod_login);
    var userSchema = mongoose.model("user", mod_user);

    //判断用户名是否存在
    loginSchema.find({login_name: loginName, login_password: loginPass},{_id: 1},function(err,docs){
        if(!err){
            console.log(docs);
            if (docs.length > 0) {
                const model = docs[0];
                const _id = model._id;

                userSchema.find({_id: _id}, {user_nickname: 1}, function(err, userDocs) {
                    if (!err) {
                        if (userDocs.length > 0) {
                            const userModel = userDocs[0];
                            const nickName = userModel.user_nickname
                            console.log("登陆成功")
                            let resultData = {
                                data: {result: 'success', _id: _id, user_nickname: nickName}
                            }
                            callback(undefined, resultData);
                        }
                    } else {
                        console.log("登陆失败")
                        let resultData = {
                            data: {result: 'failure'}
                        }
                        callback(err, resultData);
                    }
                })
            } else {
                console.log("登陆失败")
                let resultData = {
                    data: {result: 'failure'}
                }
                callback(undefined, resultData);
            }
        } else {
            console.log("登陆失败")
                let resultData = {
                    data: {result: 'failure'}
                }
                callback(err, resultData);
        }
    })
}