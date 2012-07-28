describe("data-clickarea Behaviour", function() {
  beforeEach(function() {
    loadFixtures("behaviours.html");
    location.hash = '';
  });

  it("click on the div opens the clickarea url", function() {
    $('#div').click();
    expect(location.hash).toBe('#lala');
  });

  it("click on a link within clickarea opens the link", function() {
    $('#link').click();
    expect(location.hash).not.toBe('#lala');
  });

  it("click on an span in link within clickarea opens the link", function() {
    $('#span-in-link').click();
    expect(location.hash).not.toBe('#lala');
  });

  it("click somewhere in the clickarea opens the clickarea url", function() {
    $('#somewhere').click();
    expect(location.hash).toBe('#lala');
  });
});
