svg_transparent = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" width="100%" height="100%">
  <defs>
    <!-- Planet Gradient: Light Blue to Deep Purple -->
    <linearGradient id="planetGrad" x1="85%" y1="15%" x2="15%" y2="85%">
      <!-- El gradiente rota sobre su centro (0.5 0.5) cada 20 segundos -->
      <animateTransform 
        attributeName="gradientTransform" 
        type="rotate" 
        from="0 0.5 0.5" 
        to="360 0.5 0.5" 
        dur="30s" 
        repeatCount="indefinite" 
      />
      <stop offset="0%" stop-color="#00d2ff" />
      <stop offset="30%" stop-color="#0072ff" />
      <stop offset="70%" stop-color="#4a00e0" />
      <stop offset="100%" stop-color="#1e0036" />
    </linearGradient>

    <!-- Planet Shadow (ESTÁTICO). Efecto 3D de esfera -->
    <radialGradient id="planetShadow" cx="60%" cy="40%" r="60%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.2" />
      <stop offset="50%" stop-color="#000000" stop-opacity="0.1" />
      <stop offset="90%" stop-color="#000000" stop-opacity="0.6" />
      <stop offset="100%" stop-color="#000000" stop-opacity="0.85" />
    </radialGradient>

    <!-- Orbit Line Gradient -->
    <linearGradient id="orbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ff9d00" />
      <stop offset="100%" stop-color="#ff5500" />
    </linearGradient>

    <!-- Satellite Hexagon Symbol -->
    <g id="satellite">
      <polygon points="0,-22 19,-11 19,11 0,22 -19,11 -19,-11" fill="#ff7700" opacity="0.3" transform="scale(1.3)"/>
      <polygon points="0,-18 15.6,-9 15.6,9 0,18 -15.6,9 -15.6,-9" fill="#ff9100" stroke="#ffea00" stroke-width="2"/>
      <polygon points="0,-8 6.9,-4 6.9,4 0,8 -6.9,4 -6.9,-4" fill="#ffea00" />
    </g>
  </defs>

  <style>
    .orbit-line {
      fill: none;
      stroke: url(#orbitGrad);
      stroke-width: 5;
      stroke-linecap: round;
    }
    .orbit-line-back { stroke-opacity: 0.4; }
    .orbit-line-front { stroke-opacity: 1; }
  </style>

  <!-- GROUP TILTED AT -25 DEGREES -->
  <g transform="rotate(-25 400 400)">
    
    <!-- BACK ORBIT ARC (Behind Planet) -->
    <path class="orbit-line orbit-line-back" d="M 720,400 A 320 110 0 0 0 80,400" />

    <!-- SATELLITE BEHIND -->
    <g>
      <use href="#satellite">
        <animateMotion path="M 720,400 A 320 110 0 0 0 80,400" dur="3s" begin="0s; animFront.end" id="animBack" rotate="auto" fill="freeze"/>
        <animateTransform attributeName="transform" type="scale" values="1; 0.6; 1" dur="3s" begin="0s; animFront.end"/>
        <animate attributeName="opacity" values="1; 0.6; 1" dur="3s" begin="0s; animFront.end"/>
      </use>
    </g>

    <!-- PLANET -->
    <g>
      <circle cx="400" cy="400" r="200" fill="url(#planetGrad)" />
      <!-- Detalles de superficie -->
      <ellipse cx="340" cy="380" rx="45" ry="25" fill="#ffffff" opacity="0.12" transform="rotate(-15 340 380)" />
      <ellipse cx="460" cy="460" rx="60" ry="20" fill="#ffaa00" opacity="0.08" transform="rotate(20 460 460)" />
      <circle cx="420" cy="320" r="18" fill="#00e5ff" opacity="0.15" />
      <ellipse cx="300" cy="500" rx="30" ry="15" fill="#7700ff" opacity="0.1" transform="rotate(-10 300 500)" />
      <!-- Sombra interior estática -->
      <circle cx="400" cy="400" r="200" fill="url(#planetShadow)" />
    </g>

    <!-- FRONT ORBIT ARC -->
    <path class="orbit-line orbit-line-front" d="M 80,400 A 320 110 0 0 0 720,400" />

    <!-- SATELLITE IN FRONT -->
    <g>
      <use href="#satellite">
        <animateMotion path="M 80,400 A 320 110 0 0 0 720,400" dur="3s" begin="animBack.end" id="animFront" rotate="auto" fill="freeze"/>
        <animateTransform attributeName="transform" type="scale" values="1; 1.4; 1" dur="3s" begin="animBack.end"/>
        <animate attributeName="opacity" values="1; 1; 1" dur="3s" begin="animBack.end"/>
      </use>
    </g>

  </g>
</svg>
"""

with open("planet_orbit_transparent2.svg", "w", encoding="utf-8") as f:
    f.write(svg_transparent)

print("Transparent SVG sin estrellas generado exitosamente!")
