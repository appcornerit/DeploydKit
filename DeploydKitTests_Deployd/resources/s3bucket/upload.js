//Prevent unauthorized users
if (!me) {
    cancel("You must be logged in", 401);
}
else{
    dpd.files.post({
        fileName: fileName
       ,fileSize: fileSize
    });    
}
