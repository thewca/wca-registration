describe("I want to Register for a competition", () => {
  it("shows me I have to log in if I am not logged in", () => {
    cy.visit("http://localhost:3002/");
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on register
    cy.get("a.item:nth-child(2)").click();
    // See have to log in message
    cy.get(
      "#app > main:nth-child(3) > div:nth-child(1) > div:nth-child(3) > h2:nth-child(2)"
    ).contains("You have to log in to Register for a Competition");
  });
});
