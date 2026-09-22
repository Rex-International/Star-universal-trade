import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { Search, Menu, X, ChevronRight, MapPin, Mail, Instagram, MessageCircle, ShieldCheck, Store, ShoppingBag, AlertCircle } from "lucide-react";
import "./styles.css";

const API_URL = "https://script.google.com/macros/s/AKfycbya639VDCYf0EcbgdsvSwOzcK6Q9avsyeZMSgEld-5Eh0Qy2RIXrQeW0FGYvzzur3YTog/exec";

const fallbackProducts = [
  {id:"p1",name:"Premium Product",price:"Contact seller",category:"Featured",location:"Tanzania",seller:"SUT Marketplace",image:"https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=80"},
  {id:"p2",name:"Luxury Collection",price:"Contact seller",category:"Luxury",location:"Tanzania",seller:"SUT Marketplace",image:"https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80"},
  {id:"p3",name:"Modern Essentials",price:"Contact seller",category:"Lifestyle",location:"Tanzania",seller:"SUT Marketplace",image:"https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=900&q=80"}
];

function normalize(value) {
  if (Array.isArray(value)) return value;
  if (value && Array.isArray(value.data)) return value.data;
  if (value && Array.isArray(value.products)) return value.products;
  return [];
}

async function fetchApi(action, signal) {
  const url = `${API_URL}?action=${encodeURIComponent(action)}`;
  const response = await fetch(url, { signal, headers: { Accept: "application/json" }});
  if (!response.ok) throw new Error(`API HTTP ${response.status}`);
  const type = response.headers.get("content-type") || "";
  const text = await response.text();
  if (!text.trim()) throw new Error("Empty API response");
  try { return JSON.parse(text); }
  catch { throw new Error(type.includes("json") ? "Invalid JSON response" : "API did not return JSON"); }
}

function ErrorBoundary({children}) {
  const [failed, setFailed] = useState(false);
  useEffect(() => {
    const onError = () => setFailed(true);
    window.addEventListener("error", onError);
    return () => window.removeEventListener("error", onError);
  }, []);
  if (failed) return <div className="fatal"><ShieldCheck size={42}/><h2>SUT is still available</h2><p>A page error was contained. Refresh to continue.</p><button onClick={()=>location.reload()}>Refresh</button></div>;
  return children;
}

function ContactLinks() {
  return <div className="contact-links">
    <a className="contact whatsapp" href="https://wa.me/255666465289" target="_blank" rel="noreferrer" aria-label="WhatsApp"><MessageCircle size={19}/><span>WhatsApp</span></a>
    <a className="contact instagram" href="https://instagram.com/Star_universal_trade" target="_blank" rel="noreferrer" aria-label="Instagram"><Instagram size={19}/><span>Instagram</span></a>
    <a className="contact email" href="mailto:Staruniversaltrade@gmail.com" aria-label="Email"><Mail size={19}/><span>Email</span></a>
  </div>;
}

function App() {
  const [page, setPage] = useState(window.location.pathname);
  const [menu, setMenu] = useState(false);
  const [query, setQuery] = useState("");
  const [products, setProducts] = useState(fallbackProducts);
  const [apiOnline, setApiOnline] = useState(false);
  const [selected, setSelected] = useState(null);
  const [category, setCategory] = useState("All");

  const go = (path) => {
    window.history.pushState({}, "", path);
    setPage(path);
    setMenu(false);
    window.scrollTo({top:0, behavior:"smooth"});
  };

  useEffect(() => {
    const onPop = () => setPage(window.location.pathname);
    window.addEventListener("popstate", onPop);
    return () => window.removeEventListener("popstate", onPop);
  }, []);

  useEffect(() => {
    document.title = page === "/products" ? "Products | Star Universal Trade" :
      page === "/sellers" ? "Sellers | Star Universal Trade" :
      page === "/social-commerce" ? "Social Commerce | Star Universal Trade" :
      page === "/account" ? "Account | Star Universal Trade" : "Star Universal Trade";
  }, [page]);

  useEffect(() => {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 9000);
    fetchApi("products", controller.signal)
      .then(data => {
        const rows = normalize(data);
        if (rows.length) {
          setProducts(rows.map((x,i)=>({
            id:x.id || x.ID || `api-${i}`,
            name:x.name || x.Name || x.product_name || "Product",
            price:x.price || x.Price || "Contact seller",
            category:x.category || x.Category || "General",
            location:x.location || x.Location || "International",
            seller:x.seller || x.Seller || x.store || "SUT Seller",
            image:x.image || x.Image || x.image_url || x.ImageURL || fallbackProducts[i % fallbackProducts.length].image
          })));
          setApiOnline(true);
        }
      })
      .catch(() => setApiOnline(false))
      .finally(()=>clearTimeout(timer));
    return () => { clearTimeout(timer); controller.abort(); };
  }, []);

  const categories = useMemo(() => ["All", ...new Set(products.map(p=>p.category).filter(Boolean))], [products]);
  const visible = products.filter(p => {
    const q = query.toLowerCase().trim();
    return (!q || `${p.name} ${p.category} ${p.seller} ${p.location}`.toLowerCase().includes(q)) &&
      (category === "All" || p.category === category);
  });

  const nav = [
    ["/","Home"],["/products","Products"],["/sellers","Sellers"],["/social-commerce","Social Commerce"],["/account","Account"]
  ];

  return <div className="app">
    <header className="header">
      <button className="brand" onClick={()=>go("/")} aria-label="Star Universal Trade home">
        <span className="logo">S</span><span><b>STAR UNIVERSAL</b><small>TRADE</small></span>
      </button>
      <nav className="desktop-nav">{nav.map(([p,n])=><button key={p} className={page===p?"active":""} onClick={()=>go(p)}>{n}</button>)}</nav>
      <div className="header-actions"><button className="icon-btn" onClick={()=>go("/products")}><Search size={20}/></button><button className="menu-btn" onClick={()=>setMenu(!menu)}>{menu?<X/>:<Menu/>}</button></div>
    </header>

    {menu && <div className="mobile-nav">{nav.map(([p,n])=><button key={p} onClick={()=>go(p)}>{n}<ChevronRight size={16}/></button>)}</div>}

    <main>
      {page === "/" && <section className="hero">
        <div className="hero-copy"><span className="eyebrow">REX INTERNATIONAL TECHNOLOGIES</span><h1>Trade beyond <em>borders.</em></h1><p>Discover products, connect with sellers and explore opportunities through Star Universal Trade.</p>
          <div className="hero-actions"><button className="primary" onClick={()=>go("/products")}>Explore Marketplace <ChevronRight size={18}/></button><button className="secondary" onClick={()=>go("/sellers")}>Find Sellers</button></div>
          <div className="trust"><span><ShieldCheck size={18}/> Trusted connections</span><span><Store size={18}/> Global sellers</span><span><ShoppingBag size={18}/> Direct contact</span></div>
        </div>
        <div className="hero-card"><div className="orb">S</div><span>STAR UNIVERSAL TRADE</span><small>Global marketplace</small></div>
      </section>}

      {page === "/products" && <section className="section"><div className="section-head"><div><span className="eyebrow">MARKETPLACE</span><h2>Explore products</h2></div><div className="api-status"><span className={apiOnline?"online":"offline"}></span>{apiOnline?"Live service":"Fallback catalog"}</div></div>
        <div className="searchbar"><Search size={19}/><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search products, sellers or locations..."/></div>
        <div className="chips">{categories.map(c=><button key={c} className={category===c?"selected":""} onClick={()=>setCategory(c)}>{c}</button>)}</div>
        <div className="grid">{visible.map(p=><article className="product" key={p.id} onClick={()=>setSelected(p)}><img src={p.image} onError={e=>{e.currentTarget.src=fallbackProducts[0].image}} alt=""/><div className="product-body"><span>{p.category}</span><h3>{p.name}</h3><p>{p.seller}</p><strong>{p.price}</strong><small><MapPin size={13}/>{p.location}</small></div></article>)}</div>
        {!visible.length && <div className="empty"><AlertCircle/><h3>No matching products</h3><p>Try another search or category.</p></div>}
      </section>}

      {page === "/sellers" && <section className="section"><span className="eyebrow">SELLER NETWORK</span><h2>Connect with sellers</h2><p className="lead">Explore businesses and contact sellers directly. SUT facilitates discovery and connection.</p><div className="seller-panel"><Store size={42}/><h3>Seller directory</h3><p>Seller profiles from the connected SUT data service will appear here as they are published.</p><button className="primary" onClick={()=>go("/products")}>Browse products</button></div></section>}

      {page === "/social-commerce" && <section className="section"><span className="eyebrow">SOCIAL COMMERCE</span><h2>Discover through social media</h2><p className="lead">SUT connects marketplace discovery with seller social presence.</p><div className="social-grid"><div className="social-card"><Instagram size={34}/><h3>Instagram</h3><p>Follow Star Universal Trade for updates and social commerce content.</p><a href="https://instagram.com/Star_universal_trade" target="_blank" rel="noreferrer">Open Instagram <ChevronRight size={16}/></a></div><div className="social-card"><MessageCircle size={34}/><h3>WhatsApp</h3><p>Contact SUT directly for marketplace enquiries.</p><a href="https://wa.me/255666465289" target="_blank" rel="noreferrer">Open WhatsApp <ChevronRight size={16}/></a></div></div></section>}

      {page === "/account" && <section className="section"><span className="eyebrow">ACCOUNT CENTER</span><h2>Your SUT account</h2><p className="lead">Account authentication can be connected to the approved identity service without changing the marketplace data architecture.</p><div className="account-box"><ShieldCheck size={42}/><h3>Welcome to SUT</h3><p>Sign-in controls are ready for the next authentication integration.</p><button className="primary" onClick={()=>alert("Account authentication will be connected in the approved auth phase.")}>Continue</button></div></section>}
    </main>

    <footer className="footer"><div><div className="footer-brand"><span className="logo">S</span><div><b>STAR UNIVERSAL TRADE</b><small>by Rex International Technologies</small></div></div><p>Global marketplace discovery and seller connections.</p></div><div><h4>Connect</h4><ContactLinks/></div><div><h4>Marketplace</h4><button onClick={()=>go("/products")}>Products</button><button onClick={()=>go("/sellers")}>Sellers</button><button onClick={()=>go("/social-commerce")}>Social Commerce</button></div><div><h4>Company</h4><span>Rex International Technologies</span><a href="mailto:Staruniversaltrade@gmail.com">Staruniversaltrade@gmail.com</a></div><div className="copyright">© {new Date().getFullYear()} Rex International Technologies. Star Universal Trade.</div></footer>

    {selected && <div className="modal-backdrop" onClick={()=>setSelected(null)}><div className="modal" onClick={e=>e.stopPropagation()}><button className="close" onClick={()=>setSelected(null)}><X/></button><img src={selected.image} onError={e=>e.currentTarget.src=fallbackProducts[0].image} alt=""/><div><span>{selected.category}</span><h2>{selected.name}</h2><p>{selected.seller}</p><strong>{selected.price}</strong><small><MapPin size={14}/>{selected.location}</small><a className="primary linkbtn" href="https://wa.me/255666465289" target="_blank" rel="noreferrer"><MessageCircle size={17}/> Contact SUT on WhatsApp</a></div></div></div>}
  </div>;
}

createRoot(document.getElementById("root")).render(<ErrorBoundary><App/></ErrorBoundary>);