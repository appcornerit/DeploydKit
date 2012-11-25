//Prevent unauthorized users from posting
if (!me) {
    cancel("You must be logged in", 401);
}
else{
    // Save the date created
    this.createdAt = parseInt((new Date().getTime()) / 1000, 10);//new Date().getTime();  
    this.creatorId = me.id;
    //Protect readonly/automatic properties    
    protect('updatedAt');    
    //error('Cannot set user on Photo to a user other than the current user.');    
}