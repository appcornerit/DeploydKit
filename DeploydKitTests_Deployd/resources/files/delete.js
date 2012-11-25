//Prevent unauthorized users from posting
if (!me) {
    cancel("You must be logged in", 401);
}
else{
    dpd.s3bucket.del(this.fileName, function(res, err) {
        if (err) cancel(err);
    });
}