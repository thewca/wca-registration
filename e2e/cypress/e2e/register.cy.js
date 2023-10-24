const LOCAL_FRONTEND_URL = "http://127.0.0.1:3002";

function loginAsTestCompetitor() {
  cy.visit(LOCAL_FRONTEND_URL);
  // Hover over Choose Test User
  cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
  // Click on test competitor 1
  cy.get(
    "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
  ).click();
}

function loginAsAdminCompetitor() {
  cy.visit(LOCAL_FRONTEND_URL);
  // Hover over Choose Test User
  cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
  // Click on test admin
  cy.get(
    "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(4) > a:nth-child(1)"
  ).click();
}

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
    loginAsTestCompetitor();
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

describe("I want to Update my registration", () => {
  beforeEach(() => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      console.log(result);
      expect(result[LOCAL_FRONTEND_URL]).to.deep.equal({ user: "6427" });
    });
  });

  it("allows me to update my registration", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Click on second event
    cy.get("label.event-label:nth-child(2) > input:nth-child(2)").click({
      force: true,
    });
    // Click on update Registration
    cy.get("button.ui:nth-child(2)").click();
  });
});

describe("I want to Delete my registration", () => {
  beforeEach(() => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      console.log(result);
      expect(result[LOCAL_FRONTEND_URL]).to.deep.equal({ user: "6427" });
    });
  });

  it("allows me to delete my registration", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Click on delete Registration
    cy.get("button.ui:nth-child(3)").click();
  });
});

describe("I am an Admin and I want to do admin tasks", () => {
  beforeEach(() => {
    loginAsAdminCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      console.log(result);
      expect(result[LOCAL_FRONTEND_URL]).to.deep.equal({ user: "15073" });
    });
  });

  it("allows me to approve a competitor", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on registration tab
    cy.get("a.item:nth-child(3)").click();
    // Select Competitor
    cy.get(
      "table.ui:nth-child(8) > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(1) > div:nth-child(1) > input:nth-child(1)"
    ).click({ force: true });
    // Approve Competitor
    cy.get("button.ui:nth-child(3)").click();
  });

  it("allows me to add a admin note to a competitors registration", () => {
    cy.visit(LOCAL_FRONTEND_URL);
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fist comp
    cy.get(
      "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
    ).click();
    // Click on registration tab
    cy.get("a.item:nth-child(3)").click();
    // Select Competitor
    cy.get(
      "table.ui:nth-child(4) > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2) > a:nth-child(1)"
    ).click();
    // Write a note
    cy.get("#admin-comment").type("admin note");
    // Update Registration
    cy.get("button.ui:nth-child(9)").click();
  });
});