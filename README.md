# DailyRead
本地服务流程

##安装npm 
npm install -g n  

##安装mongodb
https://www.mongodb.com/try/download/community
下载安装
解压在 /usr/local 目录，改名 mongodb
执行
export PATH=/usr/local/mongodb/bin:$PATH
mongod --dbpath /usr/local/var/mongodb --logpath /usr/local/var/log/mongodb/mongo.log --fork

##安装中间件
npm install express --save
npm install multer --save 
npm install mongoose --save

##启动npm
DEBUG=myapp:* npm start 
