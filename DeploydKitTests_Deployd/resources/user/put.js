if ((me && me.id == this.id)) {
    // Save the date created
    this.updatedAt = parseInt((new Date().getTime()) / 1000, 10); //new Date().getTime();   
    //Protect readonly/automatic properties    
    protect('createdAt');    
}
else{
    cancel("This is not you", 401);
}