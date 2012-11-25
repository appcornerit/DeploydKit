//Prevent unauthorized users
if (!me) {
    cancel("You must be logged in", 401);
}