/**
	3D visualization of OEIS A291939 
	@(#) $Id$
	2018-03-25, Georg Fischer
*/
			function world(scene, myfont) {
				// Default Vars
				var center = new THREE.Vector3(0, 0, 0);
				var size   = 300;
				var size5  = parseInt(size / 5);
				var width  = parseInt(size5 / 10); // thickness of the cylinders
				var vec    = [0,1,2,3,4,14,24,34,33,23,13,12,22,32,31,21,11,10,20,30,40,41,42,43,44
					,144,244,344,343,243,143,142,242,342,341,241,141,140,240,340,330,230,130,120,220
					,320,310,210,110,111,211,311,321,221,121,131,231,331,332,232,132,122,222,322,312
					,212,112,113,213,313,323,223,123,133,233,333,334,234,134,124,224,324,314,214,114
					,104,204,304,303,203,103,102,202,302,301,201,101,100,200,300,400,401,402,403,404
					,414,424,434,433,423,413,412,422,432,431,421,411,410,420,430,440,441,442,443,444
					,444];
				var points = [];	
				for (i = 0; i < vec.length; i ++) {
					var digx5 = parseInt(vec[i] /  10) % 10 ;
					var digy5 =          vec[i]        % 10;
					var digz5 = parseInt(vec[i] / 100) % 10;   
					// digits run from 0 to 4 or -2 to +2
					var x = center.x + (digx5 - 2) * size5;
					var y = center.y + (digy5 - 2) * size5;
					var z = center.z + (digz5 - 2) * size5;
					points.push(new THREE.Vector3(x, y, z));
				} // for i
				var shift = (size5 - width) * 0.5;

				var materials = [
					new THREE.MeshBasicMaterial({ color: 0xffffff, overdraw: 0.5 }),
					new THREE.MeshBasicMaterial({ color: 0xffffff, overdraw: 0.5 })
					];
				var color3 = new THREE.Color(0xffffff);
				for (i = 0; i < points.length - 1; i ++) {
					var group  = new THREE.Group();
					color3.setHSL(i * 0.8 / points.length, 1.0, 0.5);
					// var geometry = new THREE.BoxGeometry(width, size5, width);
					var geometry = new THREE.BoxGeometry(width * 3, width * 3, width * 3);
					geometry.translate(points[i].x, points[i].y, points[i].z);
					var line = new THREE.LineSegments(new THREE.EdgesGeometry(geometry)
						, new THREE.LineBasicMaterial({ color: color3 }));
					group.add(line);
					var material = new THREE.MeshBasicMaterial(
						{ color: color3, opacity: 0.4, transparent: true} );
					group.add(new THREE.Mesh(geometry, material));
					var geometry2 = new THREE.TextGeometry(vec[i], 
						{ font: myfont, size: 6, height: 1, curveSegments: 8 });
					geometry2.translate
							( points[i].x - width 
							, points[i].y - width / 2
							, points[i].z - width / 2
							);
					group.add(new THREE.Mesh(geometry2, materials));
					scene.add(group);
				} // for i 
			} // world
