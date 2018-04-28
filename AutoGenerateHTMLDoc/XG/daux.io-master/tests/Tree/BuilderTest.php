<?php
namespace Todaymade\Daux\Tree;

use Todaymade\Daux\Config;
use Todaymade\Daux\Daux;
use PHPUnit\Framework\TestCase;

class BuilderTest extends TestCase
{
    public function providerRemoveSorting()
    {
        return [
            ['01_before', 'before'],
            ['-Down', 'Down'],
            ['+Up', 'Up'],
            ['01_numeric', 'numeric'],
            ['01_A_File', 'A_File'],
            ['A_File', 'A_File'],
            ['01_Continuing', 'Continuing'],
            ['-01_Coming', 'Coming'],
            ['-02_Soon', 'Soon'],
            ['01_Getting_Started', 'Getting_Started'],
            ['API_Calls', 'API_Calls'],
            ['200_Something_Else-Cool', 'Something_Else-Cool'],
            ['_5_Ways_to_Be_Happy', '5_Ways_to_Be_Happy'],
            ['+02_Soon', 'Soon'],
            ['Before_but_after', 'Before_but_after'],
            ['Continuing', 'Continuing'],
            ['01_GitHub_Flavored_Markdown', 'GitHub_Flavored_Markdown'],
            ['Code_Test', 'Code_Test'],
            ['05_Code_Highlighting', 'Code_Highlighting'],
            ['1', '1'],
        ];
    }

    /**
     * @dataProvider providerRemoveSorting
     */
    public function testRemoveSorting($value, $expected)
    {
        $this->assertEquals($expected, Builder::removeSortingInformations($value));
    }

    public function testGetOrCreateDirNew()
    {
        $config = new Config;
        $config->setDocumentationDirectory('');
        $root = new Root($config);


        $dir = Builder::getOrCreateDir($root, 'directory');

        $this->assertSame($root, $dir->getParent());
        $this->assertEquals('directory', $dir->getTitle());
        $this->assertEquals('directory', $dir->getUri());
    }

    public function testGetOrCreateDirExisting()
    {
        $config = new Config;
        $config->setDocumentationDirectory('');
        $root = new Root($config);
        $directory = new Directory($root, 'directory');
        $directory->setTitle('directory');

        $dir = Builder::getOrCreateDir($root, 'directory');

        $this->assertSame($root, $dir->getParent());
        $this->assertEquals('directory', $dir->getTitle());
        $this->assertEquals('directory', $dir->getUri());
        $this->assertSame($directory, $dir);
    }

    public function getStaticRoot()
    {
        $config = new Config();
        $config->setDocumentationDirectory('');
        $config['mode'] = Daux::STATIC_MODE;
        $config['index_key'] = 'index.html';
        $config['valid_content_extensions'] = ['md'];

        return new Root($config);
    }

    public function testGetOrCreatePage()
    {
        $directory = new Directory($this->getStaticRoot(), 'dir');

        $entry = Builder::getOrCreatePage($directory, 'A Page.md');

        $this->assertSame($directory, $entry->getParent());
        $this->assertEquals('dir/A_Page.html', $entry->getUrl());
        $this->assertEquals('A_Page.html', $entry->getUri());
        $this->assertEquals('A Page', $entry->getTitle());
        $this->assertInstanceOf('Todaymade\Daux\Tree\Content', $entry);
    }

    public function testGetOrCreatePageAutoMarkdown()
    {
        $directory = new Directory($this->getStaticRoot(), 'dir');

        $entry = Builder::getOrCreatePage($directory, 'A Page');

        $this->assertSame($directory, $entry->getParent());
        $this->assertEquals('dir/A_Page.html', $entry->getUrl());
        $this->assertEquals('A_Page.html', $entry->getUri());
        $this->assertEquals('A Page', $entry->getTitle());
        $this->assertInstanceOf('Todaymade\Daux\Tree\Content', $entry);
    }

    public function testGetOrCreateIndexPage()
    {
        $directory = new Directory($this->getStaticRoot(), 'dir');
        $directory->setTitle('Tutorials');

        $entry = Builder::getOrCreatePage($directory, 'index.md');

        $this->assertSame($directory, $entry->getParent());
        $this->assertEquals('dir/index.html', $entry->getUrl());
        $this->assertEquals('Tutorials', $entry->getTitle());
        $this->assertInstanceOf('Todaymade\Daux\Tree\Content', $entry);
    }

    public function testGetOrCreatePageExisting()
    {
        $directory = new Directory($this->getStaticRoot(), 'dir');
        $existingEntry = new Content($directory, 'A_Page.html');
        $existingEntry->setContent('-');

        $entry = Builder::getOrCreatePage($directory, 'A Page.md');

        $this->assertSame($directory, $entry->getParent());
        $this->assertSame($existingEntry, $entry);
        $this->assertEquals('dir/A_Page.html', $entry->getUrl());
        $this->assertEquals('A_Page.html', $entry->getUri());
        $this->assertInstanceOf('Todaymade\Daux\Tree\Content', $entry);
    }

    public function testGetOrCreateRawPage()
    {
        $directory = new Directory($this->getStaticRoot(), 'dir');

        $entry = Builder::getOrCreatePage($directory, 'file.json');

        $this->assertSame($directory, $entry->getParent());
        $this->assertEquals('dir/file.json', $entry->getUrl());
        $this->assertEquals('file.json', $entry->getUri());
        $this->assertInstanceOf('Todaymade\Daux\Tree\ComputedRaw', $entry);
    }
}
