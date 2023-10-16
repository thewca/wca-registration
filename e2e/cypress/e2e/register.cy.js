const LOCAL_FRONTEND_URL = "http://127.0.0.1:3002";

describe("I want to Register for a competition", () => {
  it("shows me I have to log in if I am not logged in", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // See have to log in message
    cy.get(
      "#app > main:nth-child(3) > div:nth-child(1) > div:nth-child(3) > h2:nth-child(2)"
    ).contains("You have to log in to Register for a Competition");
  });

  it("allows me to register after logging in as a competitor", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Choose Test User
    cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
    // Click on the fist test competitor 1
    cy.get(
      "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      console.log(result);
      expect(result[LOCAL_FRONTEND_URL]).to.deep.equal({ user: "6427" });
    });
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Click on 3x3x3
    cy.get("label.event-label:nth-child(1) > input:nth-child(2)").click({
      force: true,
    });
    // Click on send Registration
    cy.get("button.ui:nth-child(2)").click();
  });
});
