/**
	@(#) $Id$
	Turning meander cube Fs
	2017-09-17, Georg Fischer
	with THREE.BoxGeometry
*/
			function world( scene, myfont ) {
				// Default Vars
				var group = new THREE.Group();
				var pi2 = Math.PI / 2;
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / 5);
				var width  = parseInt(size5 / 10); // thickness of the cylinders
				var vec_Kn = [0,1,2,3,4,14,24,34,33,32,31,21,22,23,13,12,11,10,20,30,40,41,42,43,44
					,144,244,344,343,342,341,241,242,243,143,142,141,140,240,340,330,320,310,210,220
					,230,130,120,110,111,112,113,123,122,121,131,132,133,233,232,231,221,222,223,213
					,212,211,311,312,313,323,322,321,331,332,333,334,324,314,214,224,234,134,124,114
					,104,204,304,303,302,301,201,202,203,103,102,101,100,200,300,400,401,402,403,404
					,414,424,434,433,432,431,421,422,423,413,412,411,410,420,430,440,441,442,443,444
					,444];
				var vec_Fs = [0,1,2,3,4,14,24,34,33,23,13,12,22,32,31,21,11,10,20,30,40,41,42,43,44
					,144,244,344,343,243,143,142,242,342,341,241,141,140,240,340,330,230,130,120,220
					,320,310,210,110,111,211,311,321,221,121,131,231,331,332,232,132,122,222,322,312
					,212,112,113,213,313,323,223,123,133,233,333,334,234,134,124,224,324,314,214,114
					,104,204,304,303,203,103,102,202,302,301,201,101,100,200,300,400,401,402,403,404
					,414,424,434,433,423,413,412,422,432,431,421,411,410,420,430,440,441,442,443,444
					,444];
				var vec_Fu = [0,1,2,3,4,14,13,12,11,10,20,30,40,41,31,21,22,32,42,43,33,23,24,34,44
					,144,134,124,123,133,143,142,132,122,121,131,141,140,130,120,110,111,112,113,114
					,104,103,102,101,100,200,300,400,401,301,201,202,302,402,403,303,203,204,304,404
					,414,314,214,213,313,413,412,312,212,211,311,411,410,310,210,220,320,420,430,330
					,230,240,340,440,441,341,241,231,331,431,421,321,221,222,322,422,432,332,232,242
					,342,442,443,343,243,233,333,433,423,323,223,224,324,424,434,334,234,244,344,444
					,444];
				var vec = vec_Fs;
				vec     = vec_Fu;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];
				var dvals  = [];	
				for ( i = 0; i < vec.length; i ++ ) {
					var digx5 = parseInt(vec[i] /  10) % 10;
					var digy5 =          vec[i]        % 10;
					var digz5 = parseInt(vec[i] / 100) % 10;
					dvals.push(digz5 * 25 + digx5 * 5 + digy5); // decimal
					// digits run from 0 to 4 or -2 to +2
					var x = center.x + (digx5 - 2) * size5;
					var y = center.y + (digy5 - 2) * size5;
					var z = center.z + (digz5 - 2) * size5;
					points.push(new THREE.Vector3(x, y, z));
				} // for i
				var shift = (size5 - width) * 0.5;
				for ( i = 0; i < points.length - 1; i ++ ) {
					var geometry = new THREE.BoxGeometry( width, size5, width );
					var diff = vec[i + 1] - vec[i]; // either +-1, +-10 or +-100
					var adiff = diff;
					if (adiff < 0) {
						adiff = - adiff;
					}
					if (false) {
					} else if (diff ==  -10) { // move in +x
						geometry.rotateZ(  pi2);
						geometry.translate(- shift, 0, 0);
					} else if (diff ==  +10) { // move in -x
						geometry.rotateZ(- pi2);
						geometry.translate(+ shift, 0, 0);
					} else if (diff ==    1) { // move in +y
						geometry.rotateZ(pi2 -  pi2);
						geometry.translate(0, + shift, 0);
					} else if (diff ==   -1) { // move in -y
						geometry.rotateZ(pi2 + pi2);
						geometry.translate(0, - shift, 0);
					} else if (diff ==  100) { // move in +z
						geometry.rotateX(+ pi2);
						geometry.translate(0, 0, + shift);
					} else if (diff == -100) { // move in -z
						geometry.rotateX(- pi2);
						geometry.translate(0, 0, - shift);
					} else if (diff ==    0) { // last vertex - a small cube only
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

					if (true) { // with annotation: node values
						var geometry2 = new THREE.TextGeometry( dvals[i], // vec[i], for base 5
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
				if (true) { // with label
						var geometry2 = new THREE.TextGeometry( "OEIS A220952",
							{ font: myfont
							, size:   16
							, height: 4
							, curveSegments: 8
							} );
						var plab = points[108];
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
