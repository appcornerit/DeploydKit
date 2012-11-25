// Save the date created
this.createdAt = parseInt((new Date().getTime()) / 1000, 10);//new Date().getTime();
//Protect readonly/automatic properties    
protect('updatedAt');      

  
