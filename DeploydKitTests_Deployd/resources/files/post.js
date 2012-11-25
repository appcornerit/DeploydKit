if (!me) {
    cancel("You must be logged in", 401);
}
else{
    this.fileName = this.id;
    //this.creatorId = me.id;
    this.uploadedAt = new Date().getTime();
}