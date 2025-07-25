const price = () => {
  console.log("=== price function called ===");

  const priceInput = document.getElementById("item-price");
  const addTaxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  console.log("priceInput:", priceInput);
  console.log("addTaxDom:", addTaxDom);
  console.log("profitDom:", profitDom);

  if (priceInput && addTaxDom && profitDom) {
    console.log("All elements found, adding event listener");
    priceInput.addEventListener("input", () => {
      console.log("Price input changed:", priceInput.value);
      const inputValue = priceInput.value;
      const tax = Math.floor(inputValue * 0.1);
      const profit = inputValue - tax;

      console.log("Calculated tax:", tax);
      console.log("Calculated profit:", profit);

      addTaxDom.innerHTML = tax;
      profitDom.innerHTML = profit;
    });
  } else {
    console.log("Some elements not found!");
  }
};

console.log("Setting up event listeners");
window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);


