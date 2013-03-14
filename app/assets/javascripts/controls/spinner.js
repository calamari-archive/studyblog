var controls = controls || {};

(function() {
  'use strict';
  /**
   * Creates a fully customized ajax spinner (loading indicator)
   * borrowed from: http://js1k.com/2010-first/source/272
   */
  controls.Spinner = function(options) {
    options = options || {};
    var width  = options.width || 24,
        height = options.height || 24,
        color  = "#000";

    var Spinner, e="canvas",f="opacity",k="fill",j=Math.PI,g="createElement",i="width",c="height",b="getContext",e="canvas",a="2d",h="rotate",d="translate";Spinner=function(A){if(!A){A={}}if(!A[e]){A[e]={}}if(!A.opacity){A.opacity={}}var z=document,t=z[g](e),m=t[b](a),r=z[g](e),x=r[b](a),l=A.iterations||8,y=A[e][i]||width,n=A[e][c]||height,s=A[e][k]||color,q=A.draw||function(C,D,B,F,E){C.beginPath();C.arc(0,-1*(B/3),D/10,0,6.283,0);C.closePath()},v=A.interval||33,w=A.rotation||3,o=(A[f].end||1)-(A[f].start||0),u=360/l;t[i]=y;t[c]=n;m[d](y/2,n/2);for(var p=0;p<l;p++){!function(){m[h]((j/180)*((A.clockwise?-1:1)*u));m.globalAlpha=o*((p+1)/l);q(m,y,n,l,p+1);m.fillStyle=s;m[k]()}()}r[i]=y;r[c]=n;x[d](y/2,n/2);this.interval=setInterval(function(){x.clearRect(-1*(y/2),-1*(n/2),y,n);x[h]((j/180)*(w+360));x.drawImage(t,0,0,y,n,-1*(y/2),-1*(n/2),y,n)},v);return r};
    return function() { return $(new Spinner()); };
  }();
}());
