function loginAsTestCompetitor() {
  cy.visit('/');
  // Hover over Choose Test User
  cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
  // Click on test competitor 1
  cy.get(
    "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)"
  ).click();
}

function loginAsOrganizerCompetitor() {
  cy.visit('/');
  // Hover over Choose Test User
  cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
  // Click on test competitor 1
  cy.get(
      "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(3) > a:nth-child(1)"
  ).click();
}

function loginAsAdminCompetitor() {
  cy.visit('/');
  // Hover over Choose Test User
  cy.get("li.dropdown:nth-child(3)").trigger("mouseover");
  // Click on test admin
  cy.get(
    "li.dropdown:nth-child(3) > ul:nth-child(2) > li:nth-child(4) > a:nth-child(1)"
  ).click();
}

describe("I want to Register for a competition", () => {
  it("shows me I have to log in if I am not logged in", () => {
    cy.visit('/');
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
      "div.icon > div:nth-child(2)"
    ).contains("You need to log in to Register for a competition");
  });

  it("allows me to register after logging in as a competitor", () => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      expect(result[Cypress.config().baseUrl]).to.deep.equal({ user: "6427" });
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

  it("does not allow me to register if I didn't set a required comment", () => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      expect(result[Cypress.config().baseUrl]).to.deep.equal({ user: "6427" });
    });
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the third comp
    cy.get(
        "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(3) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Click on first event
    cy.get("label.event-label:nth-child(1) > input:nth-child(2)").click({
      force: true,
    });
    // Make sure the button is grayed out
    cy.get("button.ui:nth-child(2)").should('be.disabled')
    // Put a comment
    cy.get("#comment").type("now we have a comment")
    // Make sure the button is no longer grayed out
    cy.get("button.ui:nth-child(2)").should('not.be.disabled')
  });
});

describe("I want to Update my registration", () => {
  beforeEach(() => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      expect(result[Cypress.config().baseUrl]).to.deep.equal({ user: "6427" });
    });
  });

  it("allows me to update my registration", () => {
    cy.visit('/');
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

  it("does not allow me to update my registration if the event deadline is over", () => {
    cy.visit('/');
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the fourth comp
    cy.get(
        "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(4) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Click on second event
    cy.get("label.event-label:nth-child(2) > input:nth-child(2)").click({
      force: true,
    });
    // Click on register
    cy.get("button.ui:nth-child(2)").click();
    cy.reload()
    // Make sure that Edit button is grayed out
    cy.get("button.ui:nth-child(2)").should('be.disabled')
  });
});

describe("I want to Delete my registration", () => {
  beforeEach(() => {
    loginAsTestCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      expect(result[Cypress.config().baseUrl]).to.deep.equal({ user: "6427" });
    });
  });

  it("allows me to delete my registration", () => {
    cy.visit('/');
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
    loginAsOrganizerCompetitor();
    // Expect the user_id to be saved in localstorage to simulate a login
    cy.getAllLocalStorage().then((result) => {
      expect(result[Cypress.config().baseUrl]).to.deep.equal({ user: "2" });
    });
  });

  it("allows me to register early", () => {
    cy.visit('/');
    // Hover of Registration System
    cy.get("li.dropdown:nth-child(2)").trigger("mouseover");
    // Click on the sixth comp
    cy.get(
        "li.dropdown:nth-child(2) > ul:nth-child(2) > li:nth-child(6) > a:nth-child(1)"
    ).click();
    // Click on register tab
    cy.get("a.item:nth-child(2)").click();
    // Ensure it shows the warning message
    cy.get(".warning").contains("Registration is not open yet, but you can still register as a competition organizer or delegate.")
    // Click on 3x3x3
    cy.get("label.event-label:nth-child(1) > input:nth-child(2)").click({
      force: true,
    });
    // Click on send Registration
    cy.get("button.ui:nth-child(2)").click();
  });

  it("allows me to approve a competitor", () => {
    cy.visit('/');
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
    cy.visit('/');
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
