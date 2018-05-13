/**
	@(#) $Id$
	Turning meander cube 4m
	2018-05-10, Georg Fischer
	with THREE.BoxGeometry
*/
			//	     world( scene, myfont, urlbase, urldecim, urllabel, urltitle, urlvec );
			function world( scene, myfont, urlbase, urldecim, urllabel, urltitle, urlvec ) {
				var withlabel = urllabel == "on";
				var withdecim = urldecim == "on";
				// Default Vars
				var base = urlbase;
				var maxvec = base * base * base;
				var last = urlvec[urlvec.length - 1];
				while (urlvec.length < maxvec) {
					urlvec.push(last);
				}
				var dbase  = withdecim ? base : 10; // base for decoding
				console.log("last " + last);
				console.log("dbase " + dbase);
				function digx(num) {
					return parseInt(num /         dbase + 0.1) % dbase;
				}
				function digy(num) {
					return          num % dbase;
				}
				function digz(num) {
					return parseInt(num / (dbase*dbase) + 0.1) % dbase;
				}
				var group = new THREE.Group();
				var pi2 = Math.PI / 2;
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / base );
				var width  = parseInt(size5 / 2 / base); // thickness of the cylinders
				var vec_4m =
 	[0,1,2,3,13,12,11,10,20,21,22,23,33,32,31,30 
     ,130,131,132,133
     ,233,232,231,230
     ,330,331,332,333
     ,323,322,321,320
     ,220,221,222,223
     ,123,122,121,120
     ,110,111,112,113
     ,213,212,211,210
     ,310,311,312,313
     ,303,302,301,300
     ,200,201,202,203
     ,103,102,101,100,100]
     ;
				var vec = urlvec;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];
				var dvals  = [];	
				var sub5   = (base - 1) / 2;
				for (i = 0; i < vec.length; i ++) {
					var digx5 = digx(vec[i]);
					var digy5 = digy(vec[i]);
					var digz5 = digz(vec[i]);
					dvals.push(digz5 * base * base + digx5 * base + digy5); // decimal
					// digits run from 0 to 4 or -2 to +2
					var x = center.x + (digx5 - sub5) * size5;
					var y = center.y + (digy5 - sub5) * size5;
					var z = center.z + (digz5 - sub5) * size5;
					points.push(new THREE.Vector3(x, y, z));
				} // for i
				var shift = (size5 - width) * 0.5;
				for ( i = 0; i < points.length - 1; i ++ ) {
					var geometry = new THREE.BoxGeometry( width, size5, width );
					var diffx = digx(vec[i + 1]) - digx(vec[i]); 
					var diffy = digy(vec[i + 1]) - digy(vec[i]); 
					var diffz = digz(vec[i + 1]) - digz(vec[i]); 
					if (false) {
					} else if (diffx == -1) { // move in +x
						geometry.rotateZ(  pi2);
						geometry.translate(- shift, 0, 0);
					} else if (diffx == +1) { // move in -x
						geometry.rotateZ(- pi2);
						geometry.translate(+ shift, 0, 0);
					} else if (diffy == +1) { // move in +y
						geometry.rotateZ(pi2 -  pi2);
						geometry.translate(0, + shift, 0);
					} else if (diffy == -1) { // move in -y
						geometry.rotateZ(pi2 + pi2);
						geometry.translate(0, - shift, 0);
					} else if (diffz == +1) { // move in +z
						geometry.rotateX(+ pi2);
						geometry.translate(0, 0, + shift);
					} else if (diffz == -1) { // move in -z
						geometry.rotateX(- pi2);
						geometry.translate(0, 0, - shift);
					} else { // last vertex - a small cube only
						geometry = new THREE.BoxGeometry( width, width, width );
					}	
					geometry.translate( points[i].x, points[i].y, points[i].z);
					if (true) { // with edges
						var edges = new THREE.EdgesGeometry( geometry );
						var line = new THREE.LineSegments( edges, new THREE.LineBasicMaterial( { color: 0xffffff } ) );
						group.add( line );
					}
					var color3 = new THREE.Color( 0xffffff );
					color3.setHSL( i * 0.8 / points.length, 1.0, 0.5 );
					var material = new THREE.MeshBasicMaterial( 
						{ color: color3
						, alphaMap: 0x000000
					//	, emissive: color3
						, flatShading: true
					//	, opacity: 0.5
					//	, wireframe: true
						} ); // 0x0000ff} );
					var mesh = new THREE.Mesh( geometry, material );
					group.add( mesh  );

					if (withlabel) { // with annotation: node values
						var geometry2 = new THREE.TextGeometry(withdecim ? dvals[i] : vec[i],
							{ font: myfont
							, size:   8
							, height: 2
							, curveSegments: 8
							} );
						geometry2.translate
								( points[i].x + width
								, points[i].y + width
								, points[i].z + width
								);
						var mesh2 = new THREE.Mesh( geometry2, materials );
						group.add( mesh2 );
						scene.add( group );
					} // node values
					scene.add( group );

				} // for i 
				if (urltitle.length > 0) { // with title
						var geometry2 = new THREE.TextGeometry( urltitle,
							{ font: myfont
							, size:   16
							, height: 4
							, curveSegments: 8
							} );
						var plab = points[base * (base - 1) + 8];
						geometry2.translate
								( plab.x - 2.7 * size5
								, plab.y + 0.4 * size5
								, plab.z - 0.0 * size5
								);
						var mesh2 = new THREE.Mesh( geometry2, materials );
						group.add( mesh2 );
						scene.add( group );
				} // node values
				scene.add( group );
			} // world
