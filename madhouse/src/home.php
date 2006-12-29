<?php
	include "rutinas.php";
	$sql ='SELECT * FROM party WHERE highlighted = 1';
	$rs = mysql_query( $sql, $conn)
		or die ( "No puedo realizar la consulta 1.");
		
	
	$xml = '<?xml version="1.0"?>';
	$xml.= '<data>';
	$xml.= '	<parties>';		
	
	while( $fila = mysql_fetch_array($rs) )
	{
		


		$xml.= '		<party>';
		$xml.= '			<id>'.$fila['id'].'</id>';
		$xml.= '			<date>'.$fila['date'].'</date>';
		$xml.= '			<category>'.$fila['category'].'</category>';
		$xml.= '			<img_0>'.$fila['img_0'].'</img_0>';
		$xml.= '			<img_1>'.$fila['img_1'].'</img_1>';
		$xml.= '			<img_2>'.$fila['img_2'].'</img_2>';
		$xml.= '			<djs>';
		$dj_ids = explode(",", $fila['dj_id'] );

		for($i = 0; $i < count($dj_ids); $i++)
		{
			//echo $i.'-'.$dj_ids[ $i ].'<BR>';
			
			$tmpSQL ='SELECT * FROM dj WHERE id = '.$dj_ids[ $i ];
			$tmpRS = mysql_query( $tmpSQL, $conn);
			while( $tmpFila = mysql_fetch_array($tmpRS) )
			{
				$xml.= '				<dj type="'.$tmpFila['type'].'">';
				$xml.= '					<img>'.$tmpFila['img'].'</img>';
				$xml.= '					<name>'.$tmpFila['name'].'</name>';
				$xml.= '					<label>'.$tmpFila['label'].'</label>';
				$xml.= '					<bio>'.$tmpFila['bio'].'</bio>';
				$xml.= '					<website>'.$tmpFila['website'].'</website>';
				$xml.= '				</dj>';			
			
			}
		
		}

		$xml.= '			</djs>';
		$xml.= '			<url_gallery>'.$fila['url_gallery'].'</url_galley>';
		$xml.= '		</party>';
	}
		$xml.= '	</parties>';
		$xml.= '</data>';
		echo $xml;
?>

