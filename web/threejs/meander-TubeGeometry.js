/**
	@(#) $Id$
	Turning meander cube Fs
	2017-09-17, Georg Fischer
	with THRREE.MeshLine
*/
			function world( scene, myfont ) {
				// Default Vars
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / 5);
				var vec_Kn = [0,1,2,3,4,14,24,34,33,32,31,21,22,23,13,12,11,10,20,30,40,41,42,43,44
					,144,244,344,343,342,341,241,242,243,143,142,141,140,240,340,330,320,310,210,220
					,230,130,120,110,111,112,113,123,122,121,131,132,133,233,232,231,221,222,223,213
					,212,211,311,312,313,323,322,321,331,332,333,334,324,314,214,224,234,134,124,114
					,104,204,304,303,302,301,201,202,203,103,102,101,100,200,300,400,401,402,403,404
					,414,424,434,433,432,431,421,422,423,413,412,411,410,420,430,440,441,442,443,444];	
				var vec_Fs = [0,1,2,3,4,14,24,34,33,23,13,12,22,32,31,21,11,10,20,30,40,41,42,43,44,
					144,244,344,343,243,143,142,242,342,341,241,141,140,240,340,330,230,130,120,220,320,
					310,210,110,111,211,311,321,221,121,131,231,331,332,232,132,122,222,322,312,212,112,
					113,213,313,323,223,123,133,233,333,334,234,134,124,224,324,314,214,114,104,204,304,
					303,203,103,102,202,302,301,201,101,100,200,300,400,401,402,403,404,414,424,434,433,
					423,413,412,422,432,431,421,411,410,420,430,440,441,442,443,444];	
				var vec = vec_Fs;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];	
				for ( i = 0; i < vec.length; i ++ ) {
					var digx5 = parseInt(vec[i] /  10) % 10 ;
					var digy5 =          vec[i]        % 10;
					var digz5 = parseInt(vec[i] / 100) % 10;
					var x = center.x + (digx5 - 2) * size5;
					var y = center.y + (digy5 - 2) * size5;
					var z = center.z + (digz5 - 2) * size5;
					points.push(new THREE.Vector3(x, y, z));
					if (false) { // with annotation: node values
						var geometry = new THREE.TextGeometry( vec[i], 
							{ font: myfont
							, size: 6
							, height: 1
							, curveSegments: 8
							} );
						var mesh = new THREE.Mesh( geometry, materials );
						mesh.position.x = x;
						mesh.position.y = y;
						mesh.position.z = z;
						var group = new THREE.Group();
						group.add( mesh );
						scene.add( group );
					} // node values
				} // for i

				var path = new THREE.CurvePath();
				for ( i = 1; i < points.length; i ++ ) {
					path.add(new THREE.LineCurve3(points[i - 1], points[i]));
				} // for i 
				var geometry = new THREE.TubeGeometry( path, 2000, 8, 4, false );
				var 
			//	material = new THREE.MeshBasicMaterial( { color: 0x00ffff } );
				material =	new THREE.MeshPhongMaterial( {
					color: 0x156289,
					emissive: 0x072534,
					side: THREE.DoubleSide,
					flatShading: true
				} )

				var mesh = new THREE.Mesh( geometry, material );
				scene.add( mesh );
/*
				var geometry3 = new THREE.Geometry();
				var colors3 = [];
				for ( var i = 0; i < points.length; i ++ ) {
					geometry3.vertices.push( points[i] );
					colors3[i] = new THREE.Color( 0xffffff );
					colors3[i].setHSL( i / points.length, 1.0, 0.5 );
				}
				// geometry3.colors = colors3;
				// lines
				var material = new MeshLineMaterial( 
					{ color: new THREE.Color(0xffffff)
					// , opacity: 0.7
					, linewidth: 100.0
					, sizeAttenuation: true
				//	, vertexColors: THREE.VertexColors 
					} );
				var line = new MeshLine();
				line.setGeometry( geometry3, function( p ) { return 10; }  );
				var mesh = new THREE.Mesh( line.geometry, material ); // this syntax could definitely be improved!
				scene.add( mesh );
*/
			} // world
