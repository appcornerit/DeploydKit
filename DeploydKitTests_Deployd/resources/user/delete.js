if (!(me && me.id == this.id)) {
  cancel("Unauthorized operation", 401);
}