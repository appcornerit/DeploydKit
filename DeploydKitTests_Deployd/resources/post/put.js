//Prevent unauthorized users from posting
if (!me) {
    cancel("You must be logged in", 401);
}
else{
    // Save the date created
    this.updatedAt = parseInt((new Date().getTime()) / 1000, 10); //new Date().getTime();   
    //Protect readonly/automatic properties    
    protect('createdAt');    
    protect('creatorId');     
}