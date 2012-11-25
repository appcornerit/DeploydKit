//Prevent unauthorized users from posting
if (!me) {
    cancel("You must be logged in", 401);
}
